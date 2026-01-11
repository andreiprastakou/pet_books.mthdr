class BookIndexEntry {
  static parse(data) {
    return {
      ...data,
      authorId: data['author_id'],
      coverUrl: data['cover_thumb_url'],
      coverFullUrl: data['cover_full_url'],
      tagIds: data['tag_ids'],
      popularity: data['popularity'],
      globalRank: data['global_rank'],
      coverDesignId: data['cover_design_id'],
    }
  }
}

export default BookIndexEntry
