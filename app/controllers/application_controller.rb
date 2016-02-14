class ApplicationController < ActionController::API

  before_filter :webhook_verify!

  def webhook
    CancelDuplicateBuildsJob.perform_in 5, webhook_repo
    head :ok
  end


  private

  def webhook_verify!
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), webhook_secret, request.body.read)
    ActiveSupport::SecurityUtils.secure_compare signature, request.headers['X-Hub-Signature']
  end

  def webhook_repo
    params.fetch('repository').fetch('name')
  end

  def webhook_secret
    Rails.application.config.rolling_travis_builds.webhook_secret
  end

end
