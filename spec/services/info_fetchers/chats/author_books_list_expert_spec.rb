require 'rails_helper'

RSpec.describe InfoFetchers::Chats::AuthorBooksListExpert do
  subject(:expert) { described_class.new }

  describe '.instructions' do
    subject(:result) { described_class.instructions }

    it 'returns configured instructions' do
      expect(result).to include(Book::STANDARD_FORMS.join(', '))
    end
  end

  describe '#ask_books_list' do
    subject(:result) { expert.ask_books_list(author) }

    let(:author) { create(:author, fullname: 'David Copperfield') }
    let(:chat) { instance_double(Ai::Chat) }
    let(:chat_response) { instance_double(RubyLLM::Message, content: chat_output) }
    let(:chat_output) do
      '{"notes": "Notes", "works": ' \
        '[["David Copperfield", null, "1850", "novel", "https://en.wikipedia.org/wiki/David_Copperfield"]]}'
    end

    before do
      allow(Ai::Chat).to receive(:start).and_return(chat)
      allow(chat).to receive(:with_instructions)
      allow(chat).to receive(:ask).with('Author: David Copperfield').and_return(chat_response)
    end

    it 'returns hashes with book data' do
      expect(result).to eq([
                             {
                               title: 'David Copperfield',
                               year_published: 1850,
                               literary_form: 'novel',
                               wiki_url: 'https://en.wikipedia.org/wiki/David_Copperfield'
                             }
                           ])
    end

    it 'sets up chat with instructions' do
      result
      expect(chat).to have_received(:with_instructions).with(described_class.instructions)
    end

    context 'when chat responds with bad JSON' do
      let(:chat_output) { 'invalid JSON' }

      it 'returns empty array and registers an error' do
        expect(result).to eq([])
        expect(expert.errors.map(&:message)).to match([/unexpected character/])
      end
    end
  end
end
