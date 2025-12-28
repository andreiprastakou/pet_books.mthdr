# == Schema Information
#
# Table name: ai_chats
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :string
#
require 'rails_helper'

RSpec.describe Ai::Chat do
  it { is_expected.to have_many(:messages).class_name(Ai::Message.name) }

  it { is_expected.to validate_presence_of(:model_id) }

  describe '.start' do
    subject(:result) { described_class.start(*args) }

    let(:args) { [] }
    let(:chat) { build_stubbed(:ai_chat) }

    before do
      allow(described_class).to receive(:create!).and_return(chat)
      allow(chat).to receive(:with_temperature).and_return(chat)
    end

    it 'creates a new chat' do
      expect(result).to eq(chat)
      expect(described_class).to have_received(:create!).with(model_id: described_class::DEFAULT_MODEL_ID)
      expect(chat).to have_received(:with_temperature).with(1)
    end

    context 'when a model_id is provided' do
      let(:args) { [model_id] }
      let(:model_id) { 'gpt-4.1' }

      it 'creates a new chat with the provided model_id' do
        result
        expect(described_class).to have_received(:create!).with(model_id: model_id)
      end
    end
  end
end
