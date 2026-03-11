require 'rails_helper'

RSpec.describe InfoFetchers::Chats::AuthorsExpert do
  subject(:fetcher) { described_class.new }

  describe '.instructions' do
    subject(:result) { described_class.instructions }

    it 'returns configured instructions' do
      expect(result).to be_a(String)
    end
  end

  describe '#ask_books_list' do
    let(:author_name) { 'Fyodor Dostoevsky' }
    let(:mock_chat) { instance_double(Ai::Chat) }
    let(:mock_response) { instance_double(RubyLLM::Message, content: expected_response.to_json) }
    let(:expected_response) do
      {
        author: {
          fullname: 'Fyodor Dostoevsky',
          original_name: 'Фёдор Достоевский',
          countries: 'Russia',
          birth_year: 1821,
          death_year: 1881
        },
        books: [
          {
            title: 'Crime and Punishment',
            original_title: 'Преступление и наказание',
            publishing_year: 1866
          },
          {
            title: 'The Brothers Karamazov',
            original_title: 'Братья Карамазовы',
            publishing_year: 1880
          }
        ]
      }.deep_stringify_keys
    end

    before do
      allow(Ai::Chat).to receive(:start).and_return(mock_chat)
      allow(mock_chat).to receive(:with_instructions).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).with(author_name).and_return(mock_response)
    end

    it 'returns parsed JSON response' do
      result = fetcher.ask_books_list(author_name)
      expect(result).to eq(expected_response)
    end

    it 'sets up chat with correct instructions' do
      fetcher.ask_books_list(author_name)
      expect(mock_chat).to have_received(:with_instructions).with(described_class.instructions)
    end

    it 'asks chat with author name' do
      fetcher.ask_books_list(author_name)
      expect(mock_chat).to have_received(:ask).with(author_name)
    end
  end
end
