class AuthorSearchEntry {
  static parse(data) {
    return {
      authorId: data['author_id'],
      label: data['label'],
    }
  }
}

export default AuthorSearchEntry
