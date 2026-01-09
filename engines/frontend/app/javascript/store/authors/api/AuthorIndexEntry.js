class AuthorIndexEntry {
  static parse(data) {
    return {
      id: data['id'],
      fullname: data['fullname'],
      booksCount: data['books_count'],
      thumbUrl: data['thumb_url'],
      birthYear: data['birth_year'],
      rank: data['rank'],
    }
  }
}

export default AuthorIndexEntry
