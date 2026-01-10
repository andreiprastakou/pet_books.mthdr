module Frontend
  class Engine < ::Rails::Engine
    isolate_namespace Frontend

    # Configure webpacker
    initializer 'frontend.webpacker' do |app|
      if defined?(Webpacker)
        app.config.webpacker.check_yarn_integrity = false
        app.config.webpacker.symlink_node_modules = false
      end
    end

    # Add main app asset paths for shared CSS
    initializer 'frontend.assets' do |app|
      app.config.assets.paths << Rails.root.join('app/assets/stylesheets')
    end
  end
end
