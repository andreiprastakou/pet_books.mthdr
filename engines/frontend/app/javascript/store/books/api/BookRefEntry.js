class BookRefEntry {
  static parse(data) {
    return {
      id: data['id'],
      year: data['year'],
      authorId: data['author_id'],
    }
  }
}

export default BookRefEntry
