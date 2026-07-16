require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MegaShop
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # libvips is installed in the Docker image (see Dockerfile); use it for image
    # analysis/variants — it's faster and lighter than ImageMagick.
    config.active_storage.variant_processor = :vips

    # Internationalization: English (default), Russian, Kyrgyz.
    # Missing ru/ky translations fall back to English.
    config.i18n.available_locales = [ :en, :ru, :ky ]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [ :en ]

    # Use RSpec + FactoryBot for generated code; skip other test scaffolding.
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Mailer previews live under spec/ now that the suite uses RSpec.
    config.action_mailer.preview_paths << Rails.root.join("spec/mailers/previews").to_s
  end
end
