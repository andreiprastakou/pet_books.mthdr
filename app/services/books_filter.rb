class BooksFilter
  def self.filtered_scope(*)
    new(*).filtered_scope
  end

  def initialize(params, scope = Book.all)
    @params = params
    @scope = scope
  end

  def filtered_scope
    apply_authors_filter
    apply_tags_filter
    apply_years_filter
    apply_ids_filter
    scope
  end

  private

  attr_reader :params, :scope

  def apply_authors_filter
    ids = Array.wrap(params[:author_id]).presence || params[:author_ids]
    return if ids.blank?

    @scope = scope.by_author(ids)
  end

  def apply_tags_filter
    ids = Array.wrap(params[:tag_id]).presence || params[:tag_ids]
    return if ids.blank?

    @scope = scope.with_tags(ids)
  end

  def apply_years_filter
    return if (years = params[:years]).blank?

    @scope = scope.where(year_published: years)
  end

  def apply_ids_filter
    return if (ids = params[:ids]).blank?

    @scope = scope.where(id: ids)
  end
end
