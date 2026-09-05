import jQuery from 'jquery'
import { objectToParams } from 'utils/objectToParams'
import SeriesIndexEntry from 'store/series/api/SeriesIndexEntry'
import SeriesRef from 'store/series/api/SeriesRef'
import SeriesSearchEntry from 'store/series/api/SeriesSearchEntry'

class ApiClient {
  static getSeriesIndex() {
    return jQuery.ajax({
      url: '/api/series/index_entries.json'
    }).then(list => list.map(entry => SeriesIndexEntry.parse(entry)))
  }

  static getSeriesIndexEntry(id) {
    return jQuery.ajax({
      url: `/api/series/index_entries/${id}.json`
    }).then(entry => SeriesIndexEntry.parse(entry))
  }

  static getSeriesRefs() {
    return jQuery.ajax({
      url: '/api/series/ref_entries.json'
    }).then(list => list.map(entry => SeriesRef.parse(entry)))
  }

  static search(key) {
    return jQuery.ajax({
      url: `/api/series/search.json${ objectToParams({ key }) }`
    }).then(entries => entries.map(entry => SeriesSearchEntry.parse(entry)))
  }
}

export default ApiClient
