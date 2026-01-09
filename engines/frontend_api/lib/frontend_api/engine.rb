module FrontendApi
  class Engine < ::Rails::Engine
    isolate_namespace FrontendApi

    # Models from main app are automatically accessible via Rails autoloading
    # No special configuration needed
  end
end
