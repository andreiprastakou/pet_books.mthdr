class SeriesSearchEntry {
  static parse(data) {
    return {
      seriesId: data['series_id'],
      label: data['label'],
    }
  }
}

export default SeriesSearchEntry
