require 'rails_helper'

RSpec.describe Admin::WikiLinkSyncJob do
  describe '#perform' do
    subject(:call) { described_class.perform_now(wiki_link.id) }

    let(:wiki_link) { create(:wiki_link) }
    let(:syncer) { instance_double(InfoFetchers::Wiki::WikiLinksSyncer) }

    before do
      allow(InfoFetchers::Wiki::WikiLinksSyncer).to receive(:new).and_return(syncer)
      allow(syncer).to receive(:sync!)
    end

    it 'syncs the wiki link' do
      call
      expect(syncer).to have_received(:sync!)
    end
  end
end
