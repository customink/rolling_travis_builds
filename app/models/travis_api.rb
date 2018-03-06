class TravisApi

  CONNECTION = Faraday.new(url: Rails.application.config.rolling_travis_builds.url) do |faraday|
    faraday.request  :url_encoded
    faraday.request  :user_agent, app: 'RollingTravisBuilds', version: '1.0.0'
    faraday.request  :request_id
    faraday.request  :request_headers,
                       authorization: %|token "#{ENV['TRAVIS_ROLLING_ACCESS_TOKEN']}"|,
                       travis_api_version: 3
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
  end


  private

  def connection
    CONNECTION
  end

  def api_builds
    @api_builds ||= connection.get("repo/customink%2F#{repo}/builds").body
  end

  def api_build_cancel!(id)
    connection.post "build/#{id}/cancel"
  end

end
