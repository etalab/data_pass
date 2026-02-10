require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Temporarily capture and filter deprecation warnings from dsfr-view-components
original_stderr = $stderr
$stderr = StringIO.new

require 'dsfr/components'

$stderr = original_stderr

# Patch Dsfr::Components to use mattr_accessor instead of ActiveSupport::Configurable
module Dsfr
  module Components
    # Remove the Configurable dependency by providing the config methods directly
    class << self
      remove_method :config if respond_to?(:config)
      remove_method :configure if respond_to?(:configure)
      remove_method :reset! if respond_to?(:reset!)

      def config
        self
      end

      def configure
        yield(config)
      end

      def reset!
        configure do |c|
          DEFAULTS.each { |k, v| c.send("#{k}=", v) }
        end
      end
    end

    # Replace config_accessor with mattr_accessor for each default
    DEFAULTS.each_key do |k|
      mattr_accessor k, default: DEFAULTS[k]
    end
  end
end

module DataPass
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.time_zone = 'Europe/Paris'
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr

    config.matomo_id = nil

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators])

    config.generators do |g|
      g.test_framework :rspec
      g.stylesheets false
      g.javascripts false
    end

    config.action_mailer.preview_paths = [Rails.root.join('spec/mailers/previews')]

    config.default_from = 'notifications@api.gouv.fr'

    config.active_support.to_time_preserves_timezone = :zone

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
