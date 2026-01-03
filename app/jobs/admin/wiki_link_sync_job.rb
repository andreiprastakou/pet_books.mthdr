module Admin
  class WikiLinkSyncJob < ApplicationJob
    queue_as :default

    def perform(wiki_link_id)
      wiki_link = WikiLink.find(wiki_link_id)
      InfoFetchers::Wiki::WikiLinksSyncer.new(wiki_link).sync!
    end
  end
end
