require 'rails_helper'

RSpec.describe '/api/books/ref_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/ref_entries/#{book.id}.json", headers: authorization_header }

    let(:book) { create(:book, year_published: 2000) }

    it 'returns book info' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        author_ids: book.author_ids,
        year: 2000
      )
    end
  end

  describe 'GET /' do
    subject(:send_request) { get '/api/books/ref_entries.json', headers: authorization_header }

    let(:book) { create(:book) }

    before { book }

    it 'returns books page and their total number' do
      send_request

      expect(response).to be_successful
      expect(json_response).to match(list: [hash_including(id: book.id)], total: 1)
    end

    context 'with read=true' do
      let(:reader) { create(:user) }
      let(:read_book) { create(:book) }
      let(:other_book) { create(:book) }

      before do
        sign_in_frontend_user!(reader)
        create(:user_book_read, user: reader, book: read_book)
        create(:user_book_read, user: create(:user), book: other_book)
      end

      it 'returns only books the current user has read' do
        get '/api/books/ref_entries.json', params: { read: true }, headers: authorization_header

        expect(response).to be_successful
        ids = json_response[:list].pluck(:id)
        expect(ids).to eq([read_book.id])
        expect(json_response[:total]).to eq(1)
      end

      it 'sorts by the newest read' do
        earlier_book = create(:book, year_published: 2020)
        later_book = create(:book, year_published: 1900)
        UserBookRead.find_by!(user: reader, book: read_book).update!(created_at: 3.days.ago)
        create(:user_book_read, user: reader, book: earlier_book, created_at: 2.days.ago)
        create(:user_book_read, user: reader, book: later_book, created_at: 1.hour.ago)
        create(:user_book_read, user: create(:user), book: earlier_book, created_at: Time.current)

        get '/api/books/ref_entries.json',
            params: { read: true, sort_by: 'latest' },
            headers: authorization_header

        expect(response).to be_successful
        expect(json_response[:list].pluck(:id)).to eq([later_book.id, earlier_book.id, read_book.id])
      end
    end

    context 'with reads_code' do
      let(:owner) { create(:user) }
      let(:reader) { create(:user) }
      let(:shared_book) { create(:book) }
      let(:private_book) { create(:book) }
      let(:sharing) { create(:user_reads_sharing, user: owner) }

      before do
        sign_in_frontend_user!(reader)
        create(:user_book_read, user: owner, book: shared_book)
        create(:user_book_read, user: reader, book: private_book)
      end

      it 'returns books read by the sharing owner' do
        get '/api/books/ref_entries.json', params: { reads_code: sharing.code }, headers: authorization_header

        expect(response).to be_successful
        ids = json_response[:list].pluck(:id)
        expect(ids).to eq([shared_book.id])
        expect(json_response[:total]).to eq(1)
      end

      it 'sorts by the sharing owner reads, newest first' do
        earlier_book = create(:book)
        create(:user_book_read, user: owner, book: earlier_book, created_at: 2.days.ago)
        UserBookRead.find_by!(user: owner, book: shared_book).update!(created_at: 1.hour.ago)
        UserBookRead.find_by!(user: reader, book: private_book).update!(created_at: Time.current)

        get '/api/books/ref_entries.json',
            params: { reads_code: sharing.code, sort_by: 'latest' },
            headers: authorization_header

        expect(response).to be_successful
        expect(json_response[:list].pluck(:id)).to eq([shared_book.id, earlier_book.id])
      end

      it 'returns no books for an unknown code' do
        get '/api/books/ref_entries.json', params: { reads_code: 'f' * 16 }, headers: authorization_header

        expect(response).to be_successful
        expect(json_response).to eq(list: [], total: 0)
      end
    end
  end
end
