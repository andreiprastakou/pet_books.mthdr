import { Controller } from '@hotwired/stimulus'

// Syncs an external-link icon and submit disabled state with a sitelink select.
export default class extends Controller {
  static targets = ['select', 'link', 'submit']
  static values = { existingUrls: Array }

  connect() {
    this.sync()
  }

  change() {
    this.sync()
  }

  sync() {
    if (!this.hasSelectTarget)
      return

    const url = this.selectTarget.value
    if (this.hasLinkTarget && url) {
      this.linkTarget.href = url
      this.linkTarget.title = url
    }

    if (this.hasSubmitTarget) {
      const existing = this.existingUrlsValue || []
      this.submitTarget.disabled = !url || existing.includes(url)
    }
  }
}
