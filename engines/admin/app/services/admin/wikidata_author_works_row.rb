# frozen_string_literal: true

module Admin
  # A single apply-UI row combining an author book and/or Wikidata work.
  WikidataAuthorWorksRow = Struct.new(
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
  ) do
    class << self
      def matched(book, work)
        wikidata_year = parse_year(work['publication_date'])
        qid = wikidata_id_for(work)
        new(
          book: book,
          work: work,
          title: work['work_label'].presence || book.title,
          old_title: book.title,
          year: wikidata_year.presence || book.year_published,
          old_year: book.year_published,
          work_type: work['type_label'],
          wikidata_id: qid,
          new_wikidata_id: new_wikidata_id?(book, qid)
        )
      end

      def book_only(book)
        new(
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

      def work_only(work)
        qid = wikidata_id_for(work)
        new(
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

      private

      def wikidata_id_for(work)
        Admin::ExternalLinkBuilders::Wikidata.normalize_id(work['work'])
      end

      def parse_year(date_string)
        Admin::Tasks::WikidataAuthorWorksFetch.parse_year(date_string)
      end

      def new_wikidata_id?(book, qid)
        qid.present? && book.external_identities.wikidata.none? { |identity| identity.external_id == qid }
      end
    end
  end
end
