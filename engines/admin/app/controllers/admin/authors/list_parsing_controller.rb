module Admin
  module Authors
    class ListParsingController < AdminController
      before_action :fetch_author, only: %i[new create edit apply]
      before_action :fetch_task, only: %i[edit apply]

      def new; end

      def edit
        prepare_form_data
      end

      def create
        task = Admin::AuthorBooksListParsingTask.setup(@author, text: params[:text])
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_author_path(@author), notice: t('notices.admin.author_books_list_parsing.create.success')
      end

      def apply
        updater = Forms::Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          @task.verified!
          redirect_to admin_data_fetch_task_path(@task), notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_data
          render :edit
        end
      end

      private

      def fetch_author
        @author = Author.find(params[:author_id])
      end

      def fetch_task
        @task = Admin::AuthorBooksListParsingTask.find(params[:id])
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch)).tap do
          @books = updater.books
        end
      end

      def prepare_form_data
        @books = @author.books.to_a
        @task.fetched_data.each do |attributes|
          attributes = attributes.with_indifferent_access
          next if apply_to_existing_book(attributes)

          book = build_book(attributes)
          @books.push book
        end
      end

      def apply_to_existing_book(attributes)
        existing_book = @books.find { |book| book.title == attributes[:title] }
        return false if existing_book.nil?

        prepared_attributes = attributes.slice(:original_title)
        prepared_attributes.merge!(
          year_published: attributes[:year], literary_form: attributes[:type],
          series_ids: existing_book.series_ids | series_ids_for_book(attributes[:series])
        ).compact
        existing_book.assign_attributes(prepared_attributes.compact)
        true
      end

      def build_book(attributes)
        Book.new(
          attributes.slice(:title, :original_title)
            .merge(
              year_published: attributes[:year],
              authors: [@author],
              literary_form: attributes[:type],
              series_ids: series_ids_for_book(attributes[:series])
            ).compact
        )
      end

      def series_ids_for_book(parsed_series_name)
        series_name = parsed_series_name&.strip
        return [] if series_name.blank?

        [Series.find_or_create_by!(name: series_name).id]
      end
    end
  end
end
