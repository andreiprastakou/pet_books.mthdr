# frozen_string_literal: true

# == Schema Information
#
# Table name: books
#
#  id                   :integer          not null, primary key
#  data_filled          :boolean          default(FALSE), not null
#  goodreads_popularity :integer
#  goodreads_rating     :float
#  goodreads_url        :string
#  literary_form        :string           default("novel"), not null
#  original_title       :string
#  popularity           :integer          default(0)
#  summary              :text
#  summary_src          :string
#  title                :string           not null
#  wiki_popularity      :integer          default(0)
#  wiki_url             :string
#  year_published       :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  author_id            :integer          not null
#
# Indexes
#
#  index_books_on_author_id            (author_id)
#  index_books_on_data_filled          (data_filled)
#  index_books_on_title_and_author_id  (title,author_id) UNIQUE
#  index_books_on_year_published       (year_published)
#
require 'rails_helper'

RSpec.describe Book do
  it { is_expected.to belong_to(:author).class_name(Author.name).required(false) }
  it { is_expected.to have_many(:tag_connections).class_name(TagConnection.name) }
  it { is_expected.to have_many(:tags).class_name(Tag.name).through(:tag_connections) }
  it { is_expected.to have_many(:wiki_page_stats).class_name(WikiPageStat.name) }

  describe 'validation' do
    subject { build(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:author_id) }
    it { is_expected.to validate_presence_of(:author_id) }
    it { is_expected.to validate_presence_of(:year_published) }
    it { is_expected.to validate_numericality_of(:year_published).only_integer }
    it { is_expected.to validate_numericality_of(:wiki_popularity).only_integer.is_greater_than_or_equal_to(0) }

    it 'has a valid factory' do
      expect(build(:book)).to be_valid
    end
  end

  describe 'before validation' do
    describe '#title' do
      it 'is stripped' do
        book = build_stubbed(:book, title: "   TITLE  \n")
        expect { book.valid? }.to change(book, :title).to('TITLE')
      end
    end
  end

  describe '#tag_ids' do
    subject(:result) { book.tag_ids }

    let(:book) { build(:book, tags: tags) }
    let(:tags) { create_list(:tag, 2) }

    it 'returns list of associated IDs' do
      expect(result).to match_array(tags.map(&:id))
    end
  end

  describe '#special_original_title?' do
    subject(:result) { book.special_original_title? }

    let(:book) { build(:book, title: 'TITLE_A', original_title: 'TITLE_B') }

    context 'when the original title is present and different from the title' do
      it { is_expected.to be true }
    end

    context 'when the original title is not present' do
      before { book.original_title = nil }

      it { is_expected.to be false }
    end

    context 'when the original title is the same as the title' do
      before { book.original_title = 'TITLE_A' }

      it { is_expected.to be false }
    end
  end

  describe '#current_tag_names' do
    subject(:result) { book.current_tag_names }

    let(:book) { build(:book, tags: tags) }
    let(:tags) { create_list(:tag, 3) }

    before { book.tag_connections[1].mark_for_destruction }

    it 'returns the current tag names' do
      expect(result).to match_array(tags.map(&:name).values_at(0, 2))
    end
  end

  describe '#current_genre_names' do
    subject(:result) { book.current_genre_names }

    let(:book) { build(:book, genres: book_genres) }
    let(:book_genres) { build_list(:book_genre, 3, genre: build_stubbed(:genre)) }

    before { book.genres[1].mark_for_destruction }

    it 'returns the current genre names' do
      expect(result).to match_array(book_genres.map(&:genre_name).values_at(0, 2))
    end
  end

  describe '#current_book_genres' do
    subject(:result) { book.current_book_genres }

    let(:book) { build(:book, genres: book_genres) }
    let(:book_genres) { build_list(:book_genre, 3, genre: build_stubbed(:genre)) }

    before { book.genres[1].mark_for_destruction }

    it 'returns the current book genres' do
      expect(result).to match_array(book_genres.values_at(0, 2))
    end
  end

  describe '#genre_names=' do
    subject(:call) { book.genre_names = genre_names }

    let(:book) { create(:book, genres: book_genres) }
    let(:book_genres) do
      [
        build(:book_genre, genre: create(:genre, name: 'genre_a')),
        build(:book_genre, genre: create(:genre, name: 'genre_b'))
      ]
    end
    let(:genre_names) { %w[genre_a genre_c] }

    it 'assigns the genres by given names' do
      book
      expect { call }.to change(Genre, :count).by(1)

      new_genre = Genre.last
      expect(new_genre.name).to eq('genre_c')
      expect(book.current_genre_names).to contain_exactly('genre_a', 'genre_c')
      expect(book.reload.current_genre_names).to contain_exactly('genre_a', 'genre_b')
    end
  end

  describe '#next_author_book' do
    subject(:result) { book.next_author_book }

    let(:book) { books[1] }
    let(:books) do
      [
        create(:book, author: author, year_published: 2020),
        create(:book, author: author, year_published: 2020),
        create(:book, author: create(:author), year_published: 2020),
        create(:book, author: author, year_published: 2020),
        create(:book, author: author, year_published: 2022),
        create(:book, author: author, year_published: 2021)
      ]
    end
    let(:author) { create(:author) }

    it 'picks the next book by year published and id ascending' do
      expect(result).to eq(books[3])
    end
  end

  describe '#small?' do
    subject(:result) { book.small? }

    let(:book) { build(:book, literary_form: %w[short short_story].sample) }

    context 'when the literary form is short' do
      it { is_expected.to be true }
    end

    context 'when the literary form is not short' do
      let(:book) { build(:book, literary_form: 'novel') }

      it { is_expected.to be false }
    end
  end
end
