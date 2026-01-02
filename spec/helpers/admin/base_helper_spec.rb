require 'rails_helper'

RSpec.describe Admin::BaseHelper do
  describe '#admin_timestamp' do
    subject(:result) { helper.admin_timestamp(time) }

    let(:time) { current_time - 3.months + 1.minute }
    let(:current_time) { Time.zone.parse('2025-07-06 12:13:14') }

    around do |example|
      Timecop.freeze(current_time) { example.run }
    end

    context 'when time is 1 hour ago or later' do
      let(:time) { current_time - 1.hour + 1.minute }

      it 'returns a formatted datetime' do
        expect(result).to eq('<span title="2025 Jul 06, 11:14 UTC">59 minutes ago</span>')
      end
    end

    context 'when time is older than 1 hour ago' do
      let(:time) { current_time - 1.hour - 1.minute }

      it 'returns a formatted datetime' do
        expect(result).to eq('<span title="2025 Jul 06, 11:12 UTC">1 hour ago</span>')
      end
    end

    context 'when time is older than 1 day ago' do
      let(:time) { current_time - 1.day - 1.minute }

      it 'returns a formatted date' do
        expect(result).to eq('<span title="2025 Jul 05, 12:12 UTC">2025 Jul 05</span>')
      end
    end

    context 'when time is older than 31 days ago' do
      let(:time) { current_time - 31.days - 1.minute }

      it 'returns a formatted datetime' do
        expect(result).to eq('<span title="2025 Jun 05, 12:12 UTC">2025 Jun</span>')
      end
    end

    context 'when time is blank' do
      let(:time) { nil }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
