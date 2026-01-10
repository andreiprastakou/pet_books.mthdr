module Admin
  module ApplicationHelper
    include Admin::BooksHelper
    include Admin::FormsHelper
    include Admin::LinksHelper

    def admin_timestamp(time)
      return if time.blank?

      full_timestamp = time.strftime('%Y %b %d, %H:%M %Z')
      time_passed = (Time.zone.now - time).round
      if time_passed < 1.hour
        content_tag(
          :span,
          "#{pluralize(time_passed / 1.minute, 'minute')} ago", title: full_timestamp
        )
      elsif time_passed < 1.day
        content_tag(:span, "#{pluralize(time_passed / 1.hour, 'hour')} ago", title: full_timestamp)
      elsif time_passed < 31.days
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
