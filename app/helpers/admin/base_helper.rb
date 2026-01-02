module Admin
  module BaseHelper
    def admin_timestamp(time)
      return if time.blank?

      full_timestamp = time.strftime('%Y %b %d, %H:%M %Z')
      if time > 1.hour.ago
        content_tag(
          :span,
          "#{pluralize(((Time.zone.now - time) / 1.minute).round, 'minute')} ago", title: full_timestamp
        )
      elsif time > 1.day.ago
        content_tag(:span, "#{pluralize(((Time.zone.now - time) / 1.hour).round, 'hour')} ago", title: full_timestamp)
      elsif time > 1.month.ago
        content_tag(:span, time.strftime('%Y %b %d'), title: full_timestamp)
      else
        content_tag(:span, time.strftime('%Y %b'), title: full_timestamp)
      end
    end

    def sortable_table_column(label, parameter)
      if sorting_params[:sort_by] == parameter
        if sorting_params[:sort_order] == 'desc'
          link_to("#{label} ↑", url_for(sort_by: parameter, sort_order: 'asc', page: 1))
        else
          link_to("#{label} ↓", url_for(sort_by: parameter, sort_order: 'desc', page: 1))
        end
      else
        link_to(label, url_for(sort_by: parameter, page: 1))
      end
    end
  end
end
