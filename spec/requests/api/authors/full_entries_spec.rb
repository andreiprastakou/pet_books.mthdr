require 'rails_helper'

RSpec.describe '/api/authors/full_entries' do
  let(:tag) { create(:tag, name: 'foo') }

  before { tag }

  describe 'GET /:id' do
    subject(:send_request) { get "/api/authors/full_entries/#{author.id}.json", headers: authorization_header }

    let(:author) { create(:author, wiki_url: 'https://en.wikipedia.org/wiki/foobar', birth_year: 1900, death_year: 2000, tags: [tag]) }
    let(:expected_response) do
      {
        id: author.id,
        fullname: author.fullname,
        photo_thumb_url: nil,
        photo_full_url: nil,
        reference: 'https://en.wikipedia.org/wiki/foobar',
        birth_year: 1900,
        death_year: 2000,
        tag_ids: [tag.id],
        books_count: 1,
        popularity: 10_000,
        rank: 0
      }
    end

    before do
      author.books << build(:book, authors: [], popularity: 10_000)
    end

    it 'returns full info' do
      send_request
      expect(response).to be_successful
      expect(response.body).to eq(expected_response.to_json)
    end
  end

  describe 'POST /' do
    subject(:send_request) do
      post '/api/authors/full_entries.json', params: { author: author_params }, headers: authorization_header
    end

    let(:author_params) do
      {
        fullname: 'Bob Bobson',
        photo_url: nil,
        wiki_url: 'https://en.wikipedia.org/wiki/foobar2',
        birth_year: 1900,
        death_year: 2000,
        tag_names: %w[foo bar]
      }
    end

    it 'creates an author and returns their id' do
      expect { send_request }.to change(Author, :count).by(1)
      expect(response).to be_successful

      author = Author.last
      expect(response.body).to match({ id: author.id }.to_json)
      aggregate_failures do
        expect(author.fullname).to eq('Bob Bobson')
        expect(author.wiki_url).to eq('https://en.wikipedia.org/wiki/foobar2')
        expect(author.birth_year).to eq(1900)
        expect(author.death_year).to eq(2000)
        expect(author.tags).to contain_exactly(tag, kind_of(Tag))
      end
    end
  end

  describe 'PUT /:id' do
    subject(:send_request) do
      put "/api/authors/full_entries/#{author.id}.json",
          params: { author: author_params }, headers: authorization_header
    end

    let(:author) { create(:author, tags: [tag]) }
    let(:author_params) do
      {
        fullname: 'Bob Bobson Jr.',
        photo_url: nil,
        wiki_url: 'https://en.wikipedia.org/wiki/foobar3',
        birth_year: 1901,
        death_year: 2001,
        tag_names: %w[foo bar]
      }
    end

    it 'updates the author and returns their id' do
      send_request
      expect(response).to be_successful
      expect(response.body).to match({}.to_json)
      author.reload
      aggregate_failures do
        expect(author.fullname).to eq('Bob Bobson Jr.')
        expect(author.wiki_url).to eq('https://en.wikipedia.org/wiki/foobar3')
        expect(author.birth_year).to eq(1901)
        expect(author.death_year).to eq(2001)
        expect(author.tags).to contain_exactly(tag, kind_of(Tag))
      end
    end

    context 'when updates contain an error' do
      let(:author_params) { super().merge(birth_year: 1.1) }

      it 'returns validation error', :aggregate_failures do
        send_request
        expect(response).to be_unprocessable
        expect(response.body).to eq({
          errors: {
            birth_year: ['must be an integer']
          }
        }.to_json)
      end
    end
  end

  describe 'DELETE /:id' do
    subject(:send_request) do
      delete "/api/authors/full_entries/#{author.id}.json", headers: authorization_header
    end

    let(:author) { create(:author) }

    before { author }

    it 'deletes the author' do
      expect { send_request }.to change(Author, :count).by(-1)
    end
  end
end
