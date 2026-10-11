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
        task = Admin::Tasks::AiAuthorWorksParse.setup(@author, text: params[:text])
        Admin::DataFetchJob.perform_later(task.id)
        redirect_to admin_author_path(@author), notice: t('notices.admin.author_books_list_parsing.create.success')
      end

      def apply
        updater = Admin::BooksBatchUpdater.new
        if apply_via_updater(updater)
          @task.verified!
          redirect_to edit_admin_author_list_parsing_path(@author, @task),
                      notice: t('notices.admin.books_batch.updates_applied')
        else
          flash.now[:error] = t('notices.admin.books_batch.failed', errors: updater.collect_errors)
          prepare_form_data
          render :edit, status: :unprocessable_content
        end
      end

      private

      def fetch_author
        @author = Admin::Author.find(params[:author_id])
      end

      def fetch_task
        @task = Admin::Tasks::AiAuthorWorksParse.find(params[:id])
      end

      def apply_via_updater(updater)
        updater.update(params.fetch(:batch)).tap do
          @books = updater.books
        end
      end

      def prepare_form_data
        @books = Admin::Book.for_scope(
          @author.books, :authors, :external_links, :wiki_links, :book_series, :series
        ).to_a
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
          year_published: attributes[:year], literary_form: attributes[:type]
        ).compact
        existing_book.assign_attributes(prepared_attributes.compact)
        preselect_series(existing_book, attributes[:series])
        true
      end

      def build_book(attributes)
        Admin::Book.new(
          attributes.slice(:title, :original_title)
            .merge(
              year_published: attributes[:year],
              authors: [@author],
              literary_form: attributes[:type]
            ).compact
        ).tap { |book| preselect_series(book, attributes[:series]) }
      end

      def preselect_series(book, parsed_series_name)
        series_name = parsed_series_name.to_s.strip
        return if series_name.blank?
        return if book.series.any? { |series| series.name == series_name }

        book.preselected_series = Array(book.preselected_series) + [series_for_name(series_name)]
      end

      def series_for_name(series_name)
        @series_for_name ||= {}
        @series_for_name[series_name] ||= Admin::Series.find_by(name: series_name) ||
                                          Admin::Series.new(name: series_name)
      end
    end
  end
end
