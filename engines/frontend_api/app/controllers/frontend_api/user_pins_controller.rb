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
      owner = pins_owner
      return model.none unless owner

      model.where(id: UserPin.where(user: owner, entity_type: model.name).select(:entity_id))
    end

    def pins_owner
      return shared_pins_user if params[:pins_code].present?

      current_user
    end

    def shared_pins_user
      UserPinsSharing.find_by(code: params[:pins_code].to_s.downcase)&.user
    end
  end
end
