class BookFull {
  static parse(data) {
    return {
      ...data,
      originalTitle: data['original_title'],
      authorIds: data['author_ids'],
      yearPublished: data['year_published'],
      tagIds: data['tag_ids'],
      wikiUrl: data['wiki_url'],
      genericLinks: data['generic_links'],
    }
  }
}

export default BookFull
