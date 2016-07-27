require_relative 'boot'

require 'action_controller/railtie'

Bundler.require(*Rails.groups)

module CrossOriginProxy
  class Application < Rails::Application
    config.time_zone = 'Tokyo'
  end
end
