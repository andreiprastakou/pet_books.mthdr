module Frontend
  class Engine < ::Rails::Engine
    isolate_namespace Frontend

    # Add main app asset paths for shared CSS
    initializer 'frontend.assets' do |app|
      app.config.assets.paths << Rails.root.join('app/assets/stylesheets')
    end
  end
end
