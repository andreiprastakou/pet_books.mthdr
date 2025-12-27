import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'input',
    'link',
  ]

  connect() {
    this.syncUrl()
  }

  syncUrl() {
    const url = this.inputTarget.value.trim()
    if (url) {
      this.linkTarget.href = url
      this.linkTarget.title = url
    } else {
      this.linkTarget.removeAttribute('href')
      this.linkTarget.removeAttribute('title')
    }
  }
}
