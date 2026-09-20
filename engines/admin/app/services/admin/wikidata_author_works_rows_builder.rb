# frozen_string_literal: true

module Admin
  # Combines an author's books with Wikidata works into table rows for apply UI.
  # Match order: Wikidata external_id, then title equality. Each book is claimed at most once.
  class WikidataAuthorWorksRowsBuilder
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

      build_rows(pairs, unmatched_works, reserved_ids)
    end

    private

    attr_reader :author, :works

    def build_rows(pairs, unmatched_works, reserved_ids)
      rows = pairs.map { |book, work| WikidataAuthorWorksRow.matched(book, work) }
      rows.concat(unmatched_books(reserved_ids).map { |book| WikidataAuthorWorksRow.book_only(book) })
      rows.concat(unmatched_works.map { |work| WikidataAuthorWorksRow.work_only(work) })
      rows.sort_by { |row| row.year.to_i }
    end

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
        book = book_for_work_qid(work, reserved_ids)
        if book
          reserved_ids.add(book.id)
          pairs << [book, work]
        else
          unmatched_works << work
        end
      end
    end

    def book_for_work_qid(work, reserved_ids)
      qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(work['work'])
      return if qid.blank?

      book = books_by_wikidata_id[qid]
      book if book && reserved_ids.exclude?(book.id)
    end

    def claim_by_title!(pairs, unmatched_works, reserved_ids)
      still_unmatched = unmatched_works.filter_map do |work|
        claim_title_match!(pairs, work, reserved_ids)
      end
      unmatched_works.replace(still_unmatched)
    end

    def claim_title_match!(pairs, work, reserved_ids)
      book = find_unreserved_book_by_title(work['work_label'], reserved_ids)
      return work unless book

      reserved_ids.add(book.id)
      pairs << [book, work]
      nil
    end

    def find_unreserved_book_by_title(title, reserved_ids)
      return if title.blank?

      books.find { |book| reserved_ids.exclude?(book.id) && book.title == title }
    end

    def unmatched_books(reserved_ids)
      books.reject { |book| reserved_ids.include?(book.id) }
    end
  end
end
