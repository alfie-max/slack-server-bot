require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SupportBot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.test_framework :rspec, views: false, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
      g.stylesheets false
      g.javascripts false
      g.view_specs false
      g.template_engine :haml
    end
  end
end
