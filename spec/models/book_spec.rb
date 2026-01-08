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

RSpec.describe Book do
  describe 'associations' do
    it { is_expected.to have_many(:tag_connections).class_name(TagConnection.name) }
    it { is_expected.to have_many(:tags).class_name(Tag.name).through(:tag_connections) }
    it { is_expected.to have_many(:wiki_links).class_name(WikiLink.name) }
    it { is_expected.to have_many(:book_authors).class_name(BookAuthor.name) }
    it { is_expected.to have_many(:authors).class_name(Author.name).through(:book_authors) }
    it { is_expected.to have_many(:book_series).class_name(BookSeries.name) }
    it { is_expected.to have_many(:series).class_name(Series.name).through(:book_series) }
    it { is_expected.to have_many(:book_collections).class_name(BookCollection.name) }
    it { is_expected.to have_many(:collections).class_name(Collection.name).through(:book_collections) }
    it { is_expected.to have_many(:book_public_lists).class_name(BookPublicList.name) }
    it { is_expected.to have_many(:public_lists).class_name(PublicList.name).through(:book_public_lists) }
  end

  describe 'validation' do
    subject { build(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:year_published) }
    it { is_expected.to validate_numericality_of(:year_published).only_integer }
    it { is_expected.to validate_numericality_of(:wiki_popularity).only_integer.is_greater_than_or_equal_to(0) }

    it 'has a valid factory' do
      expect(build(:book)).to be_valid
    end

    it 'validates uniqueness of title per author' do
      authors = create_list(:author, 3)
      create(:book, title: 'TITLE_A', authors: authors[0..1])
      variants = [
        build(:book, title: 'TITLE_A', authors: authors[2..2]),
        build(:book, title: 'TITLE_A', authors: authors[1..1]),
        build(:book, title: 'TITLE_B', authors: authors[1..1])
      ]
      expect(variants.map(&:valid?)).to eq([true, false, true])
      expect(variants[1].errors[:title]).to include('must be unique per author')
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

  describe 'scopes' do
    describe '.by_author' do
      subject(:result) { described_class.by_author(author) }

      let(:author) { authors[1] }
      let(:authors) { create_list(:author, 3) }
      let(:books) do
        [
          create(:book, authors: authors[0..1]),
          create(:book, authors: authors[1..2]),
          create(:book, authors: authors[2..2])
        ]
      end

      it 'returns the books by the author' do
        expect(result).to match_array(books[0..1])
      end
    end

    describe '.not_filled' do
      subject(:result) { described_class.not_filled }

      before { books }

      let(:books) do
        [
          create(:book, data_filled: false),
          create(:book, data_filled: true)
        ]
      end

      it 'returns the books that are not filled' do
        expect(result).to match_array(books.values_at(0))
      end
    end

    describe '.without_tasks' do
      subject(:result) { described_class.without_tasks }

      before do
        books
        create(:book_summary_task, target: books[1])
      end

      let(:books) { create_list(:book, 2) }

      it 'returns the books that have no tasks' do
        expect(result).to match_array(books.values_at(0))
      end
    end

    describe '.form_requires_summary' do
      subject(:result) { described_class.form_requires_summary }

      before { books }

      let(:books) do
        [
          create(:book, literary_form: 'novel'),
          create(:book, literary_form: 'novella'),
          create(:book, literary_form: 'short'),
          create(:book, literary_form: 'poem'),
          create(:book, literary_form: 'play'),
          create(:book, literary_form: 'comics'),
          create(:book, literary_form: 'non_fiction')
        ]
      end

      it 'returns the books that require a summary' do
        expect(result).to match_array(books.values_at(0, 1, 6))
      end
    end

    describe '.search_by_title' do
      subject(:result) { described_class.search_by_title(key) }

      let(:key) { 'Ipsum' }
      let(:books) do
        [
          create(:book, title: 'Lorem ipsum dolor'),
          create(:book, title: 'IPSUM'),
          create(:book, title: 'ipsun')
        ]
      end

      it 'returns the books that match the title' do
        expect(result).to match_array(books.values_at(0, 1))
      end
    end
  end

  it_behaves_like 'has wiki links' do
    let(:record) { build(:book) }
  end

  it_behaves_like 'has generic links'

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

  describe '#next_author_book' do
    subject(:result) { book.next_author_book }

    let(:book) { books[1] }
    let(:books) do
      [
        create(:book, authors: [author], year_published: 2020),
        create(:book, authors: [author], year_published: 2020),
        create(:book, authors: [create(:author)], year_published: 2020),
        create(:book, authors: [author], year_published: 2020),
        create(:book, authors: [author], year_published: 2022),
        create(:book, authors: [author], year_published: 2021)
      ]
    end
    let(:author) { create(:author) }

    it 'picks the next book by year published and id ascending' do
      expect(result).to eq(books[3])
    end
  end

  describe '#small?' do
    subject(:result) { book.small? }

    let(:book) { build(:book, literary_form: short_forms.sample) }
    let(:short_forms) { %w[short short_story poem comics] }

    context 'when the literary form is short' do
      it { is_expected.to be true }
    end

    context 'when the literary form is not short' do
      let(:book) { build(:book, literary_form: 'novel') }

      it { is_expected.to be false }
    end
  end

  describe '#author_names_label' do
    subject(:result) { book.author_names_label }

    let(:book) { build(:book, authors: authors) }
    let(:authors) { create_list(:author, 3) }

    it 'returns the author names label' do
      expect(result).to eq(authors.map(&:fullname).join(', '))
    end

    context 'when the book has no authors' do
      let(:book) { build(:book, authors: []) }

      it 'returns "Unknown Author"' do
        expect(result).to eq('Unknown Author')
      end
    end
  end

  describe '#legacy_author_id' do
    subject(:result) { book.legacy_author_id }

    let(:book) { build(:book, authors: authors) }
    let(:authors) { create_list(:author, 3) }

    it 'returns one author id' do
      expect(result).to eq(authors.first.id)
    end

    context 'when the book has no authors' do
      let(:book) { build(:book, authors: []) }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '#needs_data_fetch?' do
    subject(:result) { book.needs_data_fetch? }

    let(:book) { build(:book, data_filled: false, literary_form: 'novel') }

    context 'when a book is not data_filled' do
      it { is_expected.to be true }

      context 'when book literary form does not require a summary' do
        before do
          book.literary_form = (described_class::STANDARD_FORMS - described_class::FORMS_REQUIRE_SUMMARY).sample
        end

        it { is_expected.to be false }
      end

      context 'when a book has pending generative_summary_tasks' do
        before { book.generative_summary_tasks.build }

        it { is_expected.to be false }
      end

      context 'when a book has only rejected generative_summary_tasks' do
        before { book.generative_summary_tasks.build(status: 'rejected') }

        it { is_expected.to be true }
      end
    end

    context 'when a book is data_filled' do
      before { book.data_filled = true }

      it { is_expected.to be false }
    end
  end
end
