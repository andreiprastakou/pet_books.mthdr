# == Schema Information
#
# Table name: books
# Database name: primary
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
#
# Indexes
#
#  index_books_on_data_filled     (data_filled)
#  index_books_on_year_published  (year_published)
#
module Admin
  class BookForm < ::Book
    accepts_nested_attributes_for :tag_connections, allow_destroy: true
    accepts_nested_attributes_for :genres, allow_destroy: true
    accepts_nested_attributes_for :book_authors, allow_destroy: true
    accepts_nested_attributes_for :book_series, allow_destroy: true

    def current_book_genres
      genres.reject(&:marked_for_destruction?)
    end

    def current_genre_names
      current_book_genres.map(&:genre_name)
    end

    def genre_names=(names)
      names = names.map { |name| Genre.normalize_name_value(name) }.compact_blank
      book_genres_indexed = current_book_genres.index_by(&:genre_name)

      names.uniq.each do |name|
        next if book_genres_indexed.key?(name)

        genre = Genre.where(name: name).first_or_create!
        genres.build(genre: genre)
      end

      book_genres_indexed.each do |name, book_genre|
        book_genre.mark_for_destruction unless names.include?(name)
      end
    end

    def author_ids=(ids)
      ids = ids.compact_blank
      book_authors.each do |book_author|
        book_author.mark_for_destruction unless ids.include?(book_author.author_id)
      end

      ids.each do |id|
        book_authors.build(author_id: id) unless book_authors.any? { |ba| ba.author_id == id }
      end
    end

    def series_ids=(ids)
      # handle sentinel inputs
      ids = ids.compact_blank

      book_series.each do |book_series|
        book_series.mark_for_destruction unless ids.include?(book_series.series_id)
      end

      ids.each do |id|
        book_series.build(series_id: id) unless book_series.any? { |bs| bs.series_id == id }
      end
    end

    def current_tag_names
      tag_connections.reject(&:marked_for_destruction?).map(&:tag).map(&:name)
    end

    def tag_names=(new_tag_names)
      previous_tag_names = current_tag_names
      new_tag_names = new_tag_names.map { |name| Tag.normalize_name_value(name) }.compact_blank
      tag_connections.each do |tag_connection|
        tag_connection.mark_for_destruction unless new_tag_names.include?(tag_connection.tag.name)
      end

      (new_tag_names - previous_tag_names).each do |name|
        tag_connections.build(tag: Tag.where(name: name).first_or_create!)
      end
    end
  end
end
