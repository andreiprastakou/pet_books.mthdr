class SeriesIndexEntry {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
      wikiUrl: data['wiki_url'],
      genericLinks: data['generic_links'],
    }
  }
}

export default SeriesIndexEntry
