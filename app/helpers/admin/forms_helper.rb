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
                  content_tag(:span, nil, data: { name: 'oldValue', action: 'click->input-changes#resetOldValue' },
                                          class: 'b-reset-button b-old-value'),
                  '>'
                ]
              )
            end
          ]
        )
      end
    end
  end
end
