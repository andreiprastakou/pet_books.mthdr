class CoverDesign {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
      titleColor: data['title_color'],
      titleFont: data['title_font'],
      authorNameColor: data['author_name_color'],
      authorNameFont: data['author_name_font'],
      coverImage: data['cover_image'],
    }
  }
}

export default CoverDesign
