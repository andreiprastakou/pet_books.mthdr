# frozen_string_literal: true

# == Schema Information
#
# Table name: books
# Database name: primary
#
#  id              :integer          not null, primary key
#  data_filled     :boolean          default(FALSE), not null
#  literary_form   :string
#  original_title  :string
#  popularity      :integer          default(0)
#  title           :string           not null
#  wiki_popularity :integer          default(0)
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
    it { is_expected.to have_many(:tag_connections).class_name(Joins::TagConnection.name) }
    it { is_expected.to have_many(:tags).class_name(Tag.name).through(:tag_connections) }
    it { is_expected.to have_many(:book_authors).class_name(Joins::BookAuthor.name) }
    it { is_expected.to have_many(:authors).class_name(Author.name).through(:book_authors) }
    it { is_expected.to have_many(:book_series).class_name(Joins::BookSeries.name) }
    it { is_expected.to have_many(:series).class_name(Series.name).through(:book_series) }
    it { is_expected.to have_many(:book_collections).class_name(Joins::BookCollection.name) }
    it { is_expected.to have_many(:collections).class_name(Collection.name).through(:book_collections) }
    it { is_expected.to have_many(:book_public_lists).class_name(Joins::BookPublicList.name) }
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

      before { books }

      it 'returns the books by the author' do
        expect(result.map(&:id)).to match_array(books[0..1].map(&:id))
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

      before { books }

      it 'returns the books that match the title' do
        expect(result.map(&:id)).to match_array(books.values_at(0, 1).map(&:id))
      end
    end
  end

  describe '#==' do
    it 'equates Admin::Book and Book with the same id' do
      admin_book = create(:book)
      expect(described_class.find(admin_book.id)).to eq(admin_book)
    end
  end

  describe '#readonly?' do
    it 'is readonly' do
      expect(described_class.new).to be_readonly
      expect(described_class.find(create(:book).id)).to be_readonly
    end

    it 'rejects persistence' do
      book = described_class.find(create(:book).id)
      expect { book.update!(title: 'OTHER') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  it_behaves_like 'has external links'
  it_behaves_like 'has descriptions'

  describe '#primary_description' do
    subject(:result) { book.primary_description }

    let(:book) { create(:book) }

    before do
      create(:description, owner: book, text: 'Second', priority: 1)
      create(:description, owner: book, text: 'First', priority: 0)
    end

    it 'returns the lowest-priority description' do
      expect(result.text).to eq('First')
    end
  end

  describe '#description_for_source' do
    subject(:result) { book.description_for_source(source) }

    let(:book) { create(:book) }
    let(:source) { create(:book_summary_task, target: book) }

    before do
      create(:description, owner: book, text: 'Other', source_type: 'Admin::Tasks::OpenLibraryBookFetch', source_id: 1)
      create(:description, owner: book, text: 'Matching', source_type: source.class.name, source_id: source.id)
    end

    it 'returns the description for the source type' do
      expect(result.text).to eq('Matching')
    end
  end

  describe '#upsert_description_from_source!' do
    subject(:call) do
      book.upsert_description_from_source!(source, text: 'New text', source_label: 'New src')
    end

    let(:book) { create(:book) }
    let(:source) { create(:book_summary_task, target: book) }

    it 'creates a description for the source' do
      expect { call }.to change(book.descriptions, :count).by(1)
      expect(call).to have_attributes(
        text: 'New text',
        source_label: 'New src',
        source_type: source.class.name,
        source_id: source.id
      )
    end

    context 'when a description already exists for the source type' do
      let!(:existing) do
        create(:description, owner: book, text: 'Old', source_type: source.class.name, source_id: 0)
      end

      it 'updates the existing description' do
        expect { call }.not_to change(Description, :count)
        expect(existing.reload).to have_attributes(
          text: 'New text',
          source_label: 'New src',
          source_id: source.id
        )
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

    context 'when the literary form is nil' do
      let(:book) { build(:book, literary_form: nil) }

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
end
