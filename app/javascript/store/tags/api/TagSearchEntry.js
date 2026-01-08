class TagSearchEntry {
  static parse(data) {
    return {
      tagId: data['tag_id'],
      label: data['label'],
    }
  }
}

export default TagSearchEntry
