import jQuery from 'jquery'

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const nativePromise = request => Promise.resolve(request)

class ApiClient {
  static create() {
    return nativePromise(jQuery.ajax({
      url: '/api/user_pins_sharings.json',
      method: 'POST',
      headers: { 'X-CSRF-Token': csrfToken() },
    }))
  }

  static get(code) {
    return nativePromise(jQuery.ajax({
      url: `/api/user_pins_sharings/${code}.json`,
    }))
  }

  static current() {
    return nativePromise(jQuery.ajax({
      url: '/api/user_pins_sharings/current.json',
    }))
  }

  static destroy() {
    return nativePromise(jQuery.ajax({
      url: '/api/user_pins_sharings/current.json',
      method: 'DELETE',
      headers: { 'X-CSRF-Token': csrfToken() },
    }))
  }
}

export default ApiClient
