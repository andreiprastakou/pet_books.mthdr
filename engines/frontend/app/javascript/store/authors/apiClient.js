import { objectToParams } from 'utils/objectToParams'
import AuthorFull from 'store/authors/api/AuthorFull'
import AuthorIndexEntry from 'store/authors/api/AuthorIndexEntry'
import AuthorRef from 'store/authors/api/AuthorRef'
import AuthorSearchEntry from 'store/authors/api/AuthorSearchEntry'

const jQuery = window.$

class ApiClient {
  static getAuthorsRefs() {
    return jQuery.ajax({
      url: '/api/authors/ref_entries.json'
    }).then(authors => authors.map(entry => AuthorRef.parse(entry)))
  }

  static getAuthorRef(id) {
    return jQuery.ajax({
      url: `/api/authors/ref_entries/${id}.json`
    }).then(entry => AuthorRef.parse(entry))
  }

  static getAuthorsIndex({ page, perPage, sortBy } = {}) {
    const params = {
      page,
      'per_page': perPage,
      'sort_by': sortBy
    }
    return jQuery.ajax({
      url: `/api/authors/index_entries.json${ objectToParams(params) }`
    }).then(({ list, total }) => ({ total, list: list.map(entry => AuthorIndexEntry.parse(entry)) }))
  }

  static getAuthorIndexEntry(id) {
    return jQuery.ajax({
      url: `/api/authors/index_entries/${id}.json`
    }).then(entry => AuthorIndexEntry.parse(entry))
  }

  static getAuthorFull(id) {
    return jQuery.ajax({
      url: `/api/authors/full_entries/${id}.json`
    }).then(entry => AuthorFull.parse(entry))
  }

  static search(key) {
    return jQuery.ajax({
      url: `/api/authors/search.json${ objectToParams({ key }) }`
    }).then(entries => entries.map(entry => AuthorSearchEntry.parse(entry)))
  }
}

export default ApiClient
