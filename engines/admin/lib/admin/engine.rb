module Admin
  class Engine < ::Rails::Engine
    isolate_namespace Admin

    # Configure webpacker
    initializer 'admin.webpacker' do |app|
      if defined?(Webpacker)
        app.config.webpacker.check_yarn_integrity = false
        app.config.webpacker.symlink_node_modules = false
      end
    end

    # Add main app asset paths for shared CSS
    initializer 'admin.assets' do |app|
      app.config.assets.paths << Rails.root.join('app/assets/stylesheets')
    end

    # Models from main app are automatically accessible via Rails autoloading
  end
end
