class BookRefEntry {
  static parse(data) {
    return {
      id: data['id'],
      year: data['year'],
      authorIds: data['author_ids'],
    }
  }
}

export default BookRefEntry
