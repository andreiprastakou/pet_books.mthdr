module Frontend
  class ApplicationController < ::ApplicationController
    include FrontendAuthentication
  end
end
