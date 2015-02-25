# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w( sessions.css )
Rails.application.config.assets.precompile += %w( main.css )

Rails.application.config.assets.precompile += %w( angular.js )
Rails.application.config.assets.precompile += %w( active-record.js )
Rails.application.config.assets.precompile += %w( angular-ui-router.js )
Rails.application.config.assets.precompile += %w( ui-bootstrap-tpls.js )

Rails.application.config.assets.precompile += %w( app.js )
Rails.application.config.assets.precompile += %w( controllers.js )
Rails.application.config.assets.precompile += %w( services.js )
Rails.application.config.assets.precompile += %w( resources.js )
Rails.application.config.assets.precompile += %w( directives.js )
Rails.application.config.assets.precompile += %w( dashboard.js )