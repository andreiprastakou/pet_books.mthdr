# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: external_api_rate_limits
# Database name: primary
#
#  id                   :integer          not null, primary key
#  last_requested_at    :datetime
#  min_interval_seconds :float            not null
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_external_api_rate_limits_on_name  (name) UNIQUE
#
RSpec.describe Admin::ExternalApiRateLimit do
  include ActiveSupport::Testing::TimeHelpers

  subject(:rate_limit) { build(:external_api_rate_limit) }

  let(:name) { 'open_library' }
  let(:interval) { 0.5 }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:min_interval_seconds) }
    it { is_expected.to validate_numericality_of(:min_interval_seconds).is_greater_than(0) }

    it 'has a valid factory' do
      expect(rate_limit).to be_valid
    end
  end

  describe '.claim_slot!' do
    subject(:wait) { described_class.claim_slot!(name, min_interval_seconds: interval) }

    before { freeze_time }

    it 'creates the rate limit row and allows the first request immediately' do
      expect { wait }.to change(described_class, :count).by(1)
      expect(wait).to eq(0.0)

      record = described_class.find_by!(name: name)
      expect(record.min_interval_seconds).to eq(interval)
      expect(record.last_requested_at).to eq(Time.current)
    end

    context 'when a previous request reserved a recent slot' do
      before do
        create(
          :external_api_rate_limit,
          name: name,
          min_interval_seconds: interval,
          last_requested_at: Time.current
        )
      end

      it 'returns the remaining wait and reserves the next slot' do
        expect(wait).to eq(interval)

        record = described_class.find_by!(name: name)
        expect(record.last_requested_at).to eq(Time.current + interval)
      end
    end

    context 'when enough time has already elapsed' do
      before do
        create(
          :external_api_rate_limit,
          name: name,
          min_interval_seconds: interval,
          last_requested_at: Time.current - interval
        )
      end

      it 'allows the request immediately' do
        expect(wait).to eq(0.0)
        expect(described_class.find_by!(name: name).last_requested_at).to eq(Time.current)
      end
    end
  end

  describe '.throttle!' do
    it 'sleeps for the claimed wait duration' do
      allow(described_class).to receive(:claim_slot!).with(name, min_interval_seconds: interval).and_return(0.25)
      allow(described_class).to receive(:sleep)

      described_class.throttle!(name, min_interval_seconds: interval)

      expect(described_class).to have_received(:sleep).with(0.25)
    end

    it 'does not sleep when no wait is needed' do
      allow(described_class).to receive(:claim_slot!).with(name, min_interval_seconds: interval).and_return(0.0)
      allow(described_class).to receive(:sleep)

      described_class.throttle!(name, min_interval_seconds: interval)

      expect(described_class).not_to have_received(:sleep)
    end
  end
end
