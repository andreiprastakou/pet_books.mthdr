const parsePublicList = entry => ({
  publicListId: entry.public_list_id,
  publicListTypeId: entry.public_list_type_id,
  publicListTypeName: entry.public_list_type_name,
  publicListYear: entry.public_list_year,
  bookRole: entry.book_role,
})

class BookFull {
  static parse(data) {
    return {
      ...data,
      originalTitle: data['original_title'],
      authorIds: data['author_ids'],
      yearPublished: data['year_published'],
      tagIds: data['tag_ids'],
      seriesIds: data['series_ids'],
      formLabel: data['form_label'],
      wikiUrl: data['wiki_url'],
      genericLinks: data['generic_links'],
      publicLists: (data.public_lists || []).map(parsePublicList),
    }
  }
}

export default BookFull
