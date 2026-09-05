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
    apply_series_filter
    apply_years_filter
    apply_ids_filter
    scope
  end

  private

  attr_reader :params, :scope

  def apply_authors_filter
    apply_ids_param_filter(:author_id, :author_ids) { |ids| scope.by_author(ids) }
  end

  def apply_tags_filter
    apply_ids_param_filter(:tag_id, :tag_ids) { |ids| scope.with_tags(ids) }
  end

  def apply_series_filter
    apply_ids_param_filter(:series_id, :series_ids) { |ids| scope.by_series(ids) }
  end

  def apply_years_filter
    return if (years = params[:years]).blank?

    @scope = scope.where(year_published: years)
  end

  def apply_ids_filter
    return if (ids = params[:ids]).blank?

    @scope = scope.where(id: ids)
  end

  def apply_ids_param_filter(singular_key, plural_key)
    ids = Array.wrap(params[singular_key]).presence || params[plural_key]
    return if ids.blank?

    @scope = yield(ids)
  end
end
