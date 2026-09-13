class SeriesIndexEntry {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
      wikiUrl: data['wiki_url'],
      externalLinks: data['external_links'],
    }
  }
}

export default SeriesIndexEntry
