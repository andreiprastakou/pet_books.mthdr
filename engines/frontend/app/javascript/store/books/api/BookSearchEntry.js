class BookSearchEntry {
  static parse(data) {
    return {
      bookId: data['book_id'],
      title: data['title'],
      year: data['year'],
      authorIds: data['author_ids'],
    }
  }
}

export default BookSearchEntry
