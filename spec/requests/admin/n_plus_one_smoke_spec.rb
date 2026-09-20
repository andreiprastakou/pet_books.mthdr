# frozen_string_literal: true

require 'rails_helper'

# Bullet is enabled with Bullet.raise in the test environment. These requests
# exercise admin list/show pages that historically had association N+1s.
RSpec.describe 'Admin N+1 smoke' do
  def get_admin(path)
    get path, headers: authorization_header
  end

  describe 'feed review widgets' do
    before do
      books = create_list(:book, 3)
      books.each { |book| create(:book_summary_task, target: book, status: :fetched) }

      authors = create_list(:author, 3)
      authors.each do |author|
        create(:author_books_list_task, target: author, status: :fetched)
        create(:author_books_list_parsing_task, target: author, status: :fetched)
      end
    end

    it 'renders AI works widget without N+1' do
      get_admin admin_feed_ai_works_widget_path
      expect(response).to be_successful
    end

    it 'renders gaps widget without N+1' do
      get_admin admin_feed_gaps_widget_path
      expect(response).to be_successful
    end
  end

  describe 'index pages' do
    before do
      create_list(:book, 3)
      create_list(:author, 3)
      create_list(:ai_chat, 2).each do |chat|
        create_list(:ai_message, 2, chat: chat, input_tokens: 10, output_tokens: 5)
      end
    end

    it 'renders books index without N+1' do
      get_admin admin_books_path
      expect(response).to be_successful
    end

    it 'renders authors index without N+1' do
      get_admin admin_authors_path
      expect(response).to be_successful
    end

    it 'renders AI chats index without N+1' do
      get_admin admin_ai_chats_path
      expect(response).to be_successful
    end
  end

  describe 'show pages with nested associations' do
    let!(:book) { create(:book) }
    let!(:author) { book.authors.first }

    before do
      create(:cover_design, :default)
      create(:external_link, owner: book)
      create(:external_link, owner: author)
      create(:external_identity, owner: book, external_link: create(:external_link, owner: book))
      create(:external_identity, owner: author, external_link: create(:external_link, owner: author),
                                 external_resource: :wikidata, external_id: 'Q123')
    end

    it 'renders book show without N+1' do
      get_admin admin_book_path(book)
      expect(response).to be_successful
    end

    it 'renders author show without N+1' do
      get_admin admin_author_path(author)
      expect(response).to be_successful
    end
  end
end
