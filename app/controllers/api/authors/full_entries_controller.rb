module Api
  module Authors
    class FullEntriesController < Api::Authors::BaseController
      before_action :fetch_author, only: %i[show update destroy]

      protect_from_forgery with: :null_session

      def show; end

      def create
        @author = Author.new
        perform_form_create(Forms::AuthorForm.new(@author), author_params, @author)
      end

      def update
        perform_form_update(Forms::AuthorForm.new(@author), author_params)
      end

      def destroy
        @author.destroy
        render json: {}
      end

      private

      def author_params
        params.fetch(:author, {})
              .permit(:fullname,
                      :photo_url,
                      :wiki_url,
                      :birth_year,
                      :death_year,
                      tag_names: [])
      end
    end
  end
end
