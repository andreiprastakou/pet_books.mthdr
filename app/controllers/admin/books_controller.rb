module Admin
  class BooksController < AdminController
    before_action :fetch_record, only: %i[show edit update destroy]

    SORTING_MAP = %i[
      id
      title
      year_published
      wiki_popularity
      created_at
      updated_at
    ].index_by(&:to_s).freeze

    DEFAULT_BOOKS_INDEX_VIEW = 'table'.freeze

    helper_method :current_index_view

    def index
      @pagy, @books = pagy(
        apply_sort(
          Book.preload(:authors, :generative_summary_tasks),
          SORTING_MAP,
          defaults: { sort_by: 'id', sort_order: 'desc' }
        ),
        limit: 6 * 10
      )
    end

    def show
      @next_book = @book.next_author_book
      @next_summary_task = Admin::BookSummaryTask.where(status: :fetched).order(created_at: :asc).first
    end

    def new
      @book = Admin::BookForm.new
    end

    def edit; end

    def create
      @book = Admin::BookForm.new
      respond_to do |format|
        if @book.update(record_params)
          format.html { redirect_to admin_book_path(@book), notice: t('notices.admin.books.create.success') }
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      respond_to do |format|
        if @book.update(record_params)
          format.html { redirect_to admin_book_path(@book), notice: t('notices.admin.books.update.success') }
        else
          format.html { render :edit, status: :unprocessable_content }
        end
      end
    end

    def destroy
      @book.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_books_path, status: :see_other, notice: t('notices.admin.books.destroy.success')
        end
      end
    end

    private

    def fetch_record
      @book = Admin::BookForm.find(params[:id])
    end

    def record_params
      params.fetch(:book).permit(:title, :original_title, :year_published, :goodreads_url,
                                 :summary, :summary_src, :wiki_url, :literary_form, :genre,
                                 tag_names: [], genre_names: [], author_ids: [], series_ids: [])
    end

    def current_index_view
      params[:books_index_view] || DEFAULT_BOOKS_INDEX_VIEW
    end
  end
end
