import { objectToParams } from 'utils/objectToParams'
import TagIndexEntry from 'store/tags/api/TagIndexEntry'
import TagRef from 'store/tags/api/TagRef'
import TagSearchEntry from 'store/tags/api/TagSearchEntry'

const jQuery = window.$

class ApiClient {
  static getTagsIndex() {
    return jQuery.ajax({
      url: '/api/tags/index_entries.json'
    }).then(list => list.map(entry => TagIndexEntry.parse(entry)))
  }

  static getTagsIndexEntry(id) {
    return jQuery.ajax({
      url: `/api/tags/index_entries/${id}.json`
    }).then(entry => TagIndexEntry.parse(entry))
  }

  static getTagsRefs() {
    return jQuery.ajax({
      url: '/api/tags/ref_entries.json'
    }).then(list => list.map(entry => TagRef.parse(entry)))
  }

  static getTagRef(id) {
    return jQuery.ajax({
      url: `/api/tags/ref_entries/${id}.json`
    }).then(entry => TagRef.parse(entry))
  }

  static getCategories() {
    return jQuery.ajax({
      url: '/api/tags/categories.json'
    })
  }

  static search(key) {
    return jQuery.ajax({
      url: `/api/tags/search.json${ objectToParams({ key }) }`
    }).then(entries => entries.map(entry => TagSearchEntry.parse(entry)))
  }
}

export default ApiClient
