class BookForm {
  static buildServerData(formData) {
    return {
      'title': formData.title,
      'original_title': formData.originalTitle,
      'cover_url': formData.imageUrl,
      'cover_file': formData.imageFile,
      'author_id': formData.authorId,
      'year_published': formData.yearPublished,
      'tag_names': formData.tagNames,
    }
  }
}

export default BookForm
