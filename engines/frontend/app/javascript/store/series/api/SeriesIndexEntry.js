class SeriesIndexEntry {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
      externalLinks: data['external_links'],
    }
  }
}

export default SeriesIndexEntry
