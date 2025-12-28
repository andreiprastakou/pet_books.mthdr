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

    def book_authors_to_badges_entries(book)
      book.authors.map do |author|
        { label: author.fullname, id: author.id }
      end
    end
  end
end
