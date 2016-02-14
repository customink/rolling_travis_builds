Rails.application.configure do

  config.rolling_travis_builds = ActiveSupport::OrderedOptions.new

  # Generate your own using using `SecureRandom.hex(20)`
  config.rolling_travis_builds.webhook_secret = 'YOUR_SECRET_WEBHOOK_VALUE'

  # Add your organization name here.
  config.rolling_travis_builds.organization_name = 'myorg'

  # See README for generating the TravisCI access token.
  config.rolling_travis_builds.access_token = 'TRAVIS_ACCESS_TOKEN'

end
