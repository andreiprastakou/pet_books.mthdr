require 'rails_helper'

RSpec.describe Admin::DataFetchJob do
  describe '#perform' do
    subject(:call) { described_class.perform_now(task.id) }

    let(:task) { build_stubbed(:book_summary_task) }

    before do
      allow(Admin::BaseDataFetchTask).to receive(:find).and_return(task)
      allow(task).to receive(:perform)
    end

    it 'processes the data fetch task' do
      call
      expect(task).to have_received(:perform)
    end
  end
end
