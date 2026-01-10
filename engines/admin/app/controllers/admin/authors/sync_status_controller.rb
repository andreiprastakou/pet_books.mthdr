module Admin
  module Authors
    class SyncStatusController < AdminController
      def update
        @author = Author.find(params[:author_id])
        @author.update!(synced_at: Time.current.utc)
        redirect_to admin_author_path(@author), notice: t('notices.admin.author_sync_status.update.success')
      end
    end
  end
end
