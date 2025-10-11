module Admin
  class BooksController < AdminController
    before_action :set_book, only: %i[show edit update destroy]

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
          Book.preload(:author),
          SORTING_MAP,
          defaults: { sort_by: 'id', sort_order: 'desc' }
        ),
        limit: 6 * 10
      )
    end

    def show
      @next_book = Book.where(author_id: @book.author_id).where.not(id: @book.id).sample || Book.all.sample
    end

    def new
      @book = Book.new
      @form = Forms::BookForm.new(@book)
    end

    def edit
      @form = Forms::BookForm.new(@book)
    end

    def create
      @book = Book.new
      @form = Forms::BookForm.new(@book)
      respond_to do |format|
        if @form.update(admin_book_params)
          format.html { redirect_to admin_book_path(@book), notice: t('notices.admin.books.create.success') }
        else
          format.html { render :new, status: :unprocessable_content }
        end
      end
    end

    def update
      @form = Forms::BookForm.new(@book)
      respond_to do |format|
        if @form.update(admin_book_params)
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

    def set_book
      @book = Book.find(params[:id])
    end

    def admin_book_params
      params.fetch(:book).permit(:title, :original_title, :year_published, :author_id, :goodreads_url,
                                 :summary, :summary_src, :wiki_url, :literary_form, :genre,
                                 tag_names: [], genre_names: [])
    end

    def current_index_view
      params[:books_index_view] || DEFAULT_BOOKS_INDEX_VIEW
    end
  end
end
