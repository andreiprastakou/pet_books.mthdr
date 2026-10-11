module Admin
  class AdminController < Admin::ApplicationController
    layout :choose_layout
    include Pagy::Method

    helper_method :sorting_params

    private

    def choose_layout
      turbo_frame_request? ? 'turbo_rails/frame' : 'admin'
    end

    def apply_sort(scope, sorting_map, defaults: {})
      apply_sorting_defaults(defaults)
      sorting_attribute = sorting_map[sorting_params[:sort_by]]
      return scope if sorting_attribute.nil?

      scope.order(sorting_attribute => (sorting_params[:sort_order] == 'desc' ? :desc : :asc))
    end

    def apply_sorting_defaults(defaults)
      @sorting_params = defaults.merge(sorting_params)
    end

    def sorting_params
      @sorting_params ||= { sort_by: params[:sort_by], sort_order: params[:sort_order] }.compact
    end

    def destroy_record(record, success_path:, failure_path:, notice:)
      if record.destroy
        redirect_to success_path, status: :see_other, notice: notice
      else
        redirect_to failure_path, status: :see_other, alert: destroy_failure_message(record)
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      redirect_to failure_path, status: :see_other, alert: destroy_failure_message(e.record)
    rescue ActiveRecord::InvalidForeignKey
      redirect_to failure_path, status: :see_other, alert: t('notices.admin.destroy.restricted')
    end

    def destroy_failure_message(record)
      record.errors.full_messages.to_sentence.presence || t('notices.admin.destroy.restricted')
    end
  end
end
