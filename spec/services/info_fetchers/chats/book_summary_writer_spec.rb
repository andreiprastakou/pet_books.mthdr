require 'rails_helper'

RSpec.describe InfoFetchers::Chats::BookSummaryWriter do
  let(:writer) { described_class.new }

  describe '#ask' do
    subject(:result) { writer.ask(book) }

    let(:author) { build_stubbed(:author, fullname: 'F. Scott Fitzgerald') }
    let(:book) do
      build_stubbed(:book, title: 'The Great Gatsby', year_published: 1925, authors: [author], literary_form: 'novel')
    end
    let(:chat) { instance_double(Ai::Chat) }
    let(:chat_response) { instance_double(RubyLLM::Message, content: response_text) }
    let(:response_text) do
      [
        ['The Great Gatsby is a novel by F. Scott Fitzgerald.', 'Love, Money, Society', 'social_realism', 'Novel',
         'Goodreads','F. Scott Fitzgerald'],
        ['The Great Gatsby is not a novel by F. Scott Fitzgerald.', 'Society, Love, Money, Dreams', 'social_realism',
         'Novel', 'Google Books', 'F. Scott Fitzgerald']
      ].to_json
    end

    before do
      allow(writer).to receive(:chat).and_return(chat)
      allow(chat).to receive(:ask)
        .with('Novel "The Great Gatsby" (1925) by F. Scott Fitzgerald')
        .and_return(chat_response)
    end

    it 'returns several summaries of the book' do
      expect(result).to match(
        [
          { summary: 'The Great Gatsby is a novel by F. Scott Fitzgerald.',
            themes: 'Love, Money, Society', genre: 'social_realism', form: 'Novel', src: 'Goodreads',
            authors: 'F. Scott Fitzgerald' },
          { summary: 'The Great Gatsby is not a novel by F. Scott Fitzgerald.',
            themes: 'Society, Love, Money, Dreams', genre: 'social_realism', form: 'Novel', src: 'Google Books',
            authors: 'F. Scott Fitzgerald' }
        ]
      )
      expect(writer.errors).to be_empty
    end

    context 'when chat response is not a valid JSON' do
      let(:response_text) { 'x' }

      it 'returns an empty array' do
        expect(result).to eq([])
        expect(writer.errors.map(&:message)).to match([/unexpected character/])
      end
    end

    context 'when book has no specified literary form' do
      before { book.literary_form = nil }

      it 'asks chat without literary form' do
        allow(chat).to receive(:ask).and_return(chat_response)
        result
        expect(chat).to have_received(:ask).with('"The Great Gatsby" (1925) by F. Scott Fitzgerald')
      end
    end
  end

  describe '#chat' do
    subject(:result) { writer.chat }

    let(:chat) { instance_double(Ai::Chat) }

    before do
      allow(Ai::Chat).to receive(:start).and_return(chat)
      allow(chat).to receive(:with_instructions)
    end

    it 'returns a chat prefilled with instructions' do
      expect(result).to eq(chat)
      expect(chat).to have_received(:with_instructions)
    end
  end
end
