require 'rails_helper'

RSpec.describe '/api/books/full_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/full_entries/#{book.id}.json", headers: authorization_header }

    let(:book) do
      create(
        :book,
        generic_links: generic_links,
        series: series,
        summary: 'A book summary.',
        tags: tags,
        wiki_url: 'https://en.wikipedia.org/wiki/Book',
      )
    end
    let(:tags) { create_list(:tag, 2) }
    let(:series) { create_list(:series, 2) }
    let(:generic_links) { build_list(:generic_link, 2) }

    it 'renders the book' do
      book
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        title: book.title,
        original_title: book.original_title,
        author_ids: book.author_ids,
        tag_ids: tags.map(&:id),
        series_ids: series.map(&:id),
        year_published: book.year_published,
        small: false,
        summary: book.summary,
        wiki_url: book.wiki_url,
        generic_links: generic_links.map { |link| { name: link.name, url: link.url } },
      )
    end
  end
end
