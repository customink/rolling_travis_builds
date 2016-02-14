Rails.application.configure do

  config.rolling_travis_builds = ActiveSupport::OrderedOptions.new

  config.rolling_travis_builds.webhook_secret = ENV['WEBHOOK_SECRET']
  config.rolling_travis_builds.organization_name = ENV['ORG_NAME']
  config.rolling_travis_builds.access_token = ENV['TRAVIS_ACCESS_TOKEN']

end
