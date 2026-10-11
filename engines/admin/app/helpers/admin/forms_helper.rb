module Admin
  module FormsHelper
    def admin_reversible_input(old_value:, &)
      content_tag(:div, data: { controller: 'input-changes', old_value: old_value },
                        class: 'b-reversible-input-container') do
        safe_join(
          [
            capture(&),
            content_tag(:div, class: 'form-text b-info', data: { input_changes_target: 'oldValueView' }) do
              safe_join(
                [
                  'was <',
                  content_tag(:span, old_value,
                              data: { name: 'oldValueText', action: 'click->input-changes#resetOldValue' },
                              class: 'b-reset-button b-old-value'),
                  '>'
                ]
              )
            end
          ]
        )
      end
    end

    def admin_reversible_link_input(old_value:, &)
      content_tag(:div, data: { controller: 'input-changes', old_value: old_value },
                        class: 'b-reversible-input-container') do
        safe_join(
          [
            capture(&),
            content_tag(:div, class: 'form-text b-info', data: { input_changes_target: 'oldValueView' }) do
              safe_join(
                [
                  'was <',
                  content_tag(:span, '🔗', data: { action: 'click->input-changes#resetOldValue' },
                                          class: 'b-reset-button b-old-value', title: old_value),
                  '>'
                ]
              )
            end
          ]
        )
      end
    end

    def admin_literary_form_choices
      LiteraryForm::DEFAULTS.map { |form| [form.humanize, form] }
    end

    def admin_literary_form_select_tag(name, selected, **)
      selected_value = LiteraryForm::DEFAULTS.include?(selected.to_s) ? selected : nil
      select_tag(name, options_for_select(admin_literary_form_choices, selected_value), include_blank: true, **)
    end

    def admin_literary_form_warning(*values)
      unknown = values.flatten.filter_map { |value| value.to_s.strip.presence }.uniq
                      .reject { |value| LiteraryForm::DEFAULTS.include?(value) }
      safe_join(unknown.map { |value| admin_literary_form_warning_tag(value) })
    end

    # Through-associations read the database, so unsaved batch joins would render as empty badges.
    def prepare_batch_association_badges!(books)
      replace_association_from_joins!(books, :book_authors, :author, :authors)
      replace_association_from_joins!(books, :book_series, :series, :series)
    end

    def authors_to_badges_entries(authors)
      authors.map do |author|
        { label: author.fullname, id: author.id }
      end
    end

    def series_to_badges_entries(series)
      series.map do |series|
        { label: series.name, id: series.id }
      end
    end

    def books_to_badges_entries(books)
      books.map do |book|
        {
          label: book_label_for_badges(book),
          id: book.id
        }
      end
    end

    def external_links_to_input_entries(external_links)
      map_external_records_to_input_entries(external_links, :url)
    end

    def external_identities_to_input_entries(external_identities)
      map_external_records_to_input_entries(external_identities, :external_id)
    end

    def descriptions_to_input_entries(descriptions)
      descriptions.map do |description|
        {
          id: description.id,
          text: description.text,
          source_label: description.source_label,
          display_source_label: description.display_source_label,
          priority: description.priority,
          source_type: description.source_type,
          source_id: description.source_id
        }
      end
    end

    private

    def replace_association_from_joins!(books, joins_name, record_name, target_name)
      books_with_joins = books.select { |book| book.association(joins_name).loaded? }
      return if books_with_joins.empty?

      found = records_for_unloaded_joins(books_with_joins, joins_name, record_name)
      books_with_joins.each do |book|
        assign_join_target(book, joins_name, record_name, target_name, found)
      end
    end

    def records_for_unloaded_joins(books, joins_name, record_name)
      missing_ids = books.flat_map { |book| active_joins(book, joins_name) }.filter_map do |join|
        join.public_send(:"#{record_name}_id") unless join.association(record_name).loaded?
      end
      return {} if missing_ids.empty?

      model_for_join_record(record_name).where(id: missing_ids.uniq).index_by(&:id)
    end

    def assign_join_target(book, joins_name, record_name, target_name, found)
      records = active_joins(book, joins_name).filter_map { |join| join_record(join, record_name, found) }
      association = book.association(target_name)
      association.target = records
      association.loaded!
    end

    def active_joins(book, joins_name)
      book.association(joins_name).target.reject(&:marked_for_destruction?)
    end

    def join_record(join, record_name, found)
      return join.public_send(record_name) if join.association(record_name).loaded?

      found[join.public_send(:"#{record_name}_id")]
    end

    def model_for_join_record(record_name)
      record_name == :author ? Admin::Author : Admin::Series
    end

    def admin_literary_form_warning_tag(value)
      content_tag(:div, class: 'form-text text-warning') do
        safe_join(["Current value '".html_safe, value, "' will be replaced!".html_safe])
      end
    end

    def map_external_records_to_input_entries(records, value_key)
      records.map do |record|
        {
          id: record.id,
          external_resource: record.external_resource,
          value_key => record.public_send(value_key)
        }
      end
    end
  end
end
