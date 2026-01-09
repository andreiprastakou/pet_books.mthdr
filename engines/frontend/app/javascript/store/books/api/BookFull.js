class BookFull {
  static parse(data) {
    return {
      ...data,
      originalTitle: data['original_title'],
      imageUrl: data['cover_thumb_url'],
      imageFile: null,
      authorId: data['author_id'],
      yearPublished: data['year_published'],
      tagIds: data['tag_ids']
    }
  }
}

export default BookFull
