class SeriesRef {
  static parse(data) {
    return {
      id: data['id'],
      name: data['name'],
    }
  }
}

export default SeriesRef
