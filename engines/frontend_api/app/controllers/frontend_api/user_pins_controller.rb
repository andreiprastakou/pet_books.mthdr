# frozen_string_literal: true

module FrontendApi
  class UserPinsController < FrontendApi::BaseController
    def index
      @authors = pinned(::Author).sort_by { |author| author.fullname.upcase }
      @books = pinned(::Book).preload(:authors).sort_by { |book| book.title.upcase }
      @series_list = pinned(::Series).sort_by { |series| series.name.upcase }
    end

    private

    def pinned(model)
      model.where(id: UserPin.where(user: current_user, entity_type: model.name).select(:entity_id))
    end
  end
end
