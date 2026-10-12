import jQuery from 'jquery'

class ApiClient {
  static getPinBoard(code) {
    const request = { url: '/api/user_pins.json' }
    if (code) request.data = { 'pins_code': code }

    return jQuery.ajax(request).then(data => ({
      authors: data.authors || [],
      books: data.books || [],
      series: data.series || [],
    }))
  }
}

export default ApiClient
