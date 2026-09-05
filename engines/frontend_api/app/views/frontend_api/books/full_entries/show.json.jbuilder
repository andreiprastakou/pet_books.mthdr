# frozen_string_literal: true

book = @book
json.id book.id
json.title book.title
json.original_title book.original_title
json.author_ids book.author_ids
json.year_published book.year_published
json.tag_ids book.tag_ids
json.series_ids book.series_ids
json.small book.small?
json.form_label Books::FormLabel.call(book)
json.summary book.summary
json.wiki_url book.wiki_url
json.generic_links(book.generic_links.map { |link| { name: link.name, url: link.url } })
json.public_lists(book.book_public_lists.sort_by do |entry|
  [-entry.public_list.year, entry.public_list.public_list_type.name.downcase]
end) do |book_public_list|
  public_list = book_public_list.public_list
  json.public_list_id public_list.id
  json.public_list_type_id public_list.public_list_type_id
  json.public_list_type_name public_list.public_list_type.name
  json.public_list_year public_list.year
  json.book_role book_public_list.role
end
