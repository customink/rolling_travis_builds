class TravisApi

  CONNECTION = Faraday.new(url: Rails.application.config.rolling_travis_builds.url) do |faraday|
    faraday.request  :url_encoded
    faraday.request  :user_agent, app: 'RollingTravisBuilds', version: '1.0.0'
    faraday.request  :request_id
    faraday.request  :request_headers,
                       authorization: %|token "#{Rails.application.config.rolling_travis_builds.access_token}"|,
                       accept: 'application/vnd.travis-ci.2+json'
    faraday.use      :extended_logging, logger: Rails.logger
    faraday.response :json, content_type: /\bjson$/
    faraday.adapter  :patron
  end

  ACTIVE_STATES = ['created', 'started', 'queued'].freeze

  class << self

    def cancel_duplicate_builds!(repo, options = {})
      new(repo, options).cancel_duplicate_builds!
    end

  end

  def initialize(repo, options = {})
    options.reverse_merge! branches: true
    @repo = repo
    @options = options
  end

  def repo
    @repo
  end

  def branches?
    @options[:branches]
  end

  def active_builds
    @active_builds ||= begin
      builds = api_builds.fetch('builds').select { |b| b.fetch('state').in?(ACTIVE_STATES) }
      builds.each do |build|
        build['branch'] = api_builds.fetch('commits').detect { |c| c['id'] == build['commit_id'] }.fetch('branch')
      end
    end
  end

  def duplicate_builds
    seen = []
    active_builds.select do |build|
      build_pr = build.fetch 'pull_request_number'
      build_br = build.fetch 'branch'
      next if !build_pr && !branches?
      id = build_pr || build_br
      if seen.include?(id)
        true
      else
        seen << id
        false
      end
    end
  end

  def cancel_duplicate_builds!
    ids = duplicate_builds.map { |b| b.fetch 'id' }
    ids.each { |id| api_build_cancel!(id) }
    job_ids = duplicate_builds.map { |b| b.fetch 'job_ids' }.flatten
    job_ids.each { |job_id| api_job_cancel!(job_id) }
  end


  private

  def connection
    CONNECTION
  end

  def api_builds
    @api_builds ||= connection.get("repos/#{api_organization}/#{repo}/builds").body
  end

  def api_build_cancel!(id)
    connection.post "builds/#{id}/cancel"
  end

  def api_job_cancel!(job_id)
    connection.post "jobs/#{job_id}/cancel"
  end

  def api_organization
    Rails.application.config.rolling_travis_builds.organization_name
  end

end
