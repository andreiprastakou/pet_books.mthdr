# frozen_string_literal: true

module Admin
  # Combines an author's books with Wikidata works into table rows for apply UI.
  # Match order: Wikidata external_id, then title equality. Each book is claimed at most once.
  class WikidataAuthorWorksRowsBuilder
    Row = Struct.new(
      :book,
      :work,
      :title,
      :old_title,
      :year,
      :old_year,
      :work_type,
      :wikidata_id,
      :new_wikidata_id,
      keyword_init: true
    )

    def self.call(author:, works:)
      new(author: author, works: works).call
    end

    def initialize(author:, works:)
      @author = author
      @works = Array(works)
    end

    def call
      reserved_ids = Set.new
      pairs = []
      unmatched_works = []

      claim_by_external_id!(pairs, unmatched_works, reserved_ids)
      claim_by_title!(pairs, unmatched_works, reserved_ids)

      rows = pairs.map { |book, work| matched_row(book, work) }
      rows.concat(unmatched_books(reserved_ids).map { |book| book_only_row(book) })
      rows.concat(unmatched_works.map { |work| work_only_row(work) })
      rows.sort_by { |row| row.year.to_i }
    end

    private

    attr_reader :author, :works

    def books
      @books ||= Admin::Book.cast_collection(
        Admin::Book.for_scope(author.books, :external_identities).to_a
      )
    end

    def books_by_wikidata_id
      @books_by_wikidata_id ||= books.each_with_object({}) do |book, index|
        book.external_identities.wikidata.each do |identity|
          index[identity.external_id] ||= book
        end
      end
    end

    def claim_by_external_id!(pairs, unmatched_works, reserved_ids)
      works.each do |work|
        qid = wikidata_id_for(work)
        book = qid.present? ? books_by_wikidata_id[qid] : nil
        if book && reserved_ids.exclude?(book.id)
          reserved_ids.add(book.id)
          pairs << [book, work]
        else
          unmatched_works << work
        end
      end
    end

    def claim_by_title!(pairs, unmatched_works, reserved_ids)
      still_unmatched = []

      unmatched_works.each do |work|
        book = find_unreserved_book_by_title(work['work_label'], reserved_ids)
        if book
          reserved_ids.add(book.id)
          pairs << [book, work]
        else
          still_unmatched << work
        end
      end

      unmatched_works.replace(still_unmatched)
    end

    def find_unreserved_book_by_title(title, reserved_ids)
      return if title.blank?

      books.find { |book| reserved_ids.exclude?(book.id) && book.title == title }
    end

    def unmatched_books(reserved_ids)
      books.reject { |book| reserved_ids.include?(book.id) }
    end

    def matched_row(book, work)
      wikidata_year = parse_year(work['publication_date'])
      qid = wikidata_id_for(work)
      Row.new(
        book: book,
        work: work,
        title: work['work_label'].presence || book.title,
        old_title: book.title,
        year: wikidata_year.presence || book.year_published,
        old_year: book.year_published,
        work_type: work['type_label'],
        wikidata_id: qid,
        new_wikidata_id: qid.present? && book.external_identities.wikidata.none? { |i| i.external_id == qid }
      )
    end

    def book_only_row(book)
      Row.new(
        book: book,
        work: nil,
        title: book.title,
        old_title: nil,
        year: book.year_published,
        old_year: nil,
        work_type: nil,
        wikidata_id: nil,
        new_wikidata_id: false
      )
    end

    def work_only_row(work)
      qid = wikidata_id_for(work)
      Row.new(
        book: nil,
        work: work,
        title: work['work_label'],
        old_title: nil,
        year: parse_year(work['publication_date']),
        old_year: nil,
        work_type: work['type_label'],
        wikidata_id: qid,
        new_wikidata_id: qid.present?
      )
    end

    def wikidata_id_for(work)
      Admin::ExternalLinkBuilders::Wikidata.normalize_id(work['work'])
    end

    def parse_year(date_string)
      Admin::Tasks::WikidataAuthorWorksFetch.parse_year(date_string)
    end
  end
end
