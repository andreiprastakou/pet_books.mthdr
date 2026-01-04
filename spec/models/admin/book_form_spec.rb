# frozen_string_literal: true

# == Schema Information
#
# Table name: books
# Database name: primary
#
#  id              :integer          not null, primary key
#  data_filled     :boolean          default(FALSE), not null
#  literary_form   :string           default("novel"), not null
#  original_title  :string
#  popularity      :integer          default(0)
#  summary         :text
#  summary_src     :string
#  title           :string           not null
#  wiki_popularity :integer          default(0)
#  wiki_url        :string
#  year_published  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_books_on_data_filled     (data_filled)
#  index_books_on_year_published  (year_published)
#
require 'rails_helper'

RSpec.describe Admin::BookForm do
  let(:sentinel) { '' }

  it 'has a valid factory' do
    expect(build(:admin_book_form)).to be_valid
  end

  describe '#current_genre_names' do
    subject(:result) { book.current_genre_names }

    let(:book) { build(:admin_book_form, genres: book_genres) }
    let(:book_genres) { build_list(:book_genre, 3, genre: build_stubbed(:genre)) }

    before { book.genres[1].mark_for_destruction }

    it 'returns the current genre names' do
      expect(result).to match_array(book_genres.map(&:genre_name).values_at(0, 2))
    end
  end

  describe '#current_book_genres' do
    subject(:result) { book.current_book_genres }

    let(:book) { build(:admin_book_form, genres: book_genres) }
    let(:book_genres) { build_list(:book_genre, 3, genre: build_stubbed(:genre)) }

    before { book.genres[1].mark_for_destruction }

    it 'returns the current book genres' do
      expect(result).to match_array(book_genres.values_at(0, 2))
    end
  end

  describe '#genre_names=' do
    subject(:call) { book.genre_names = genre_names }

    let(:book) { create(:admin_book_form, genres: book_genres) }
    let(:book_genres) do
      [
        build(:book_genre, genre: create(:genre, name: 'genre_a')),
        build(:book_genre, genre: create(:genre, name: 'genre_b'))
      ]
    end
    let(:genre_names) { %w[genre_a genre_c] + [sentinel] }

    it 'assigns the genres by given names' do
      book
      expect { call }.to change(Genre, :count).by(1)

      new_genre = Genre.last
      expect(new_genre.name).to eq('genre_c')
      expect(book.current_genre_names).to contain_exactly('genre_a', 'genre_c')
      expect(book.reload.current_genre_names).to contain_exactly('genre_a', 'genre_b')
    end
  end

  describe '#author_ids=' do
    subject(:call) { book.author_ids = author_ids }

    let(:book) { create(:admin_book_form, authors: [], book_authors: initial_book_authors) }
    let(:authors) { create_list(:author, 3) }
    let(:initial_book_authors) { [build(:book_author, author: authors[0]), build(:book_author, author: authors[1])] }
    let(:author_ids) { [authors[1].id, authors[2].id, sentinel] }

    it 'assigns the authors by given ids' do
      book
      expect { call }.not_to change(BookAuthor, :count)
      expect(book.book_authors.map(&:author_id)).to eq(authors[0..2].map(&:id))
      expect(book.book_authors.map(&:marked_for_destruction?)).to eq([true, false, false])
      expect(book.book_authors.map(&:new_record?)).to eq([false, false, true])
    end
  end

  describe '#series_ids=' do
    subject(:call) { book.series_ids = series_ids }

    let(:book) { create(:admin_book_form, book_series: initial_book_series) }
    let(:series) { create_list(:series, 3) }
    let(:initial_book_series) { [build(:book_series, series: series[0]), build(:book_series, series: series[1])] }
    let(:series_ids) { [series[1].id, series[2].id, sentinel] }

    it 'assigns the series by given ids' do
      book
      expect { call }.not_to change(BookSeries, :count)
      expect(book.book_series.map(&:series_id)).to eq(series[0..2].map(&:id))
      expect(book.book_series.map(&:marked_for_destruction?)).to eq([true, false, false])
      expect(book.book_series.map(&:new_record?)).to eq([false, false, true])
    end
  end

  describe '#current_tag_names' do
    subject(:result) { book.current_tag_names }

    let(:book) { build(:admin_book_form, tags: tags) }
    let(:tags) { create_list(:tag, 3) }

    before { book.tag_connections[1].mark_for_destruction }

    it 'returns the current tag names' do
      expect(result).to match_array(tags.map(&:name).values_at(0, 2))
    end
  end

  describe '#tag_names=' do
    subject(:call) { book.tag_names = tag_names }

    let(:book) { create(:admin_book_form, tags: tags[0..1]) }
    let(:tags) { create_list(:tag, 3) }
    let(:tag_names) { tags[1..2].map(&:name) + %w[tag_d] + [sentinel] }

    it 'assigns the tags by given names', :aggregate_failures do
      book
      expect { call }.to change(Tag, :count).by(1)

      new_tag = Tag.last
      expect(new_tag.name).to eq('tag_d')
      expect(book.current_tag_names).to match_array(tag_names.compact_blank)
      expect(book.tag_connections.map(&:marked_for_destruction?)).to eq([true, false, false, false])
      expect(book.tag_connections.map(&:new_record?)).to eq([false, false, true, true])
    end
  end
end
