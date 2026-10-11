module FrontendApi
  class ApplicationController < ::ApplicationController
    include FrontendAuthentication
  end
end
