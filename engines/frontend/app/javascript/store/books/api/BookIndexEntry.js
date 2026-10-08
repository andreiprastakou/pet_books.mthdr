class BookIndexEntry {
  static parse(data) {
    return {
      ...data,
      authorIds: data['author_ids'],
      tagIds: data['tag_ids'],
      popularity: data['popularity'],
      globalRank: data['global_rank'],
      coverDesignId: data['cover_design_id'],
      format: data['format'],
    }
  }
}

export default BookIndexEntry
