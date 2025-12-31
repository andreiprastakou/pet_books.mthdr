require 'rails_helper'

RSpec.describe InfoFetchers::Chats::AuthorBooksListParser do
  subject(:parser) { described_class.new }

  describe '#parse_books_list' do
    subject(:result) { parser.parse_books_list(text) }

    let(:text) { 'David Copperfield, 1850, novel' }
    let(:chat) { instance_double(Ai::Chat) }
    let(:chat_response) { instance_double(RubyLLM::Message, content: chat_output) }
    let(:chat_output) { '[["David Copperfield", "David Copperfield", 1850, "SERIES_A", "novel"]]' }

    before do
      allow(Ai::Chat).to receive(:start).and_return(chat)
      allow(chat).to receive(:with_instructions)
      allow(chat).to receive(:ask).with(text).and_return(chat_response)
    end

    it 'parses books list' do
      expect(result).to eq([{
        title: 'David Copperfield', original_title: 'David Copperfield',
        year: 1850, series: 'SERIES_A', type: 'novel'
      }])
    end

    it 'sets up chat with instructions' do
      result
      expect(chat).to have_received(:with_instructions).with(described_class::INSTRUCTIONS)
    end

    context 'when chat responds with bad JSON' do
      let(:chat_output) { 'invalid JSON' }

      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
  end
end
