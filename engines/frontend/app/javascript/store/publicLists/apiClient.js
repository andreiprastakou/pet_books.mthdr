import jQuery from 'jquery'

class ApiClient {
  static getTypes() {
    return jQuery.ajax({ url: '/api/public_list_types.json' })
  }

  static getType(id) {
    return jQuery.ajax({ url: `/api/public_list_types/${id}.json` })
  }

  static getList(id) {
    return jQuery.ajax({ url: `/api/public_lists/${id}.json` })
  }
}

export default ApiClient
