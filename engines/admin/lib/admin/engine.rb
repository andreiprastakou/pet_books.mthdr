module Admin
  class Engine < ::Rails::Engine
    isolate_namespace Admin

    # Add main app asset paths for shared CSS
    initializer 'admin.assets' do |app|
      app.config.assets.paths << Rails.root.join('app/assets/stylesheets')
    end

    # Models from main app are automatically accessible via Rails autoloading
  end
end
