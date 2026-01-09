class TagRef {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
      categoryId: data['category_id'],
      connectionsCount: data['connections_count'],
    }
  }
}

export default TagRef
