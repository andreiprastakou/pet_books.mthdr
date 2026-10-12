class AuthorFull {
  static parse(data) {
    return {
      id: data['id'],
      fullname: data['fullname'],
      booksCount: data['books_count'],
      thumbUrl: data['photo_thumb_url'],
      imageUrl: data['photo_full_url'],
      birthYear: data['birth_year'],
      deathYear: data['death_year'],
      description: data['description'] || null,
      descriptionSource: data['description_source'] || null,
      tagIds: data['tag_ids'],
      popularity: data['popularity'],
      rank: data['rank'],
      pinned: Boolean(data['pinned']),
      externalLinks: data['external_links'] || [],
    }
  }
}

export default AuthorFull
