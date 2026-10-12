import jQuery from 'jquery'

class ApiClient {
  static getPinBoard() {
    return jQuery.ajax({
      url: '/api/user_pins.json',
    }).then(data => ({
      authors: data.authors || [],
      books: data.books || [],
      series: data.series || [],
    }))
  }
}

export default ApiClient
