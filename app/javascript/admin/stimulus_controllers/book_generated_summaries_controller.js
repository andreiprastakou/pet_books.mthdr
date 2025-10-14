import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  async onPick(event) {
    const { verificationUrl, ...bookParams } = event.params
    const response = await fetch(verificationUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })

    if (response.ok) {
      this.dispatch('pickSummary', { detail: bookParams })
    } else {
      console.error('Failed to update summary:', response.statusText)
    }
  }

  onAddAllTags(event) {
    this.dispatch('addTags', { detail: event.params })
  }
}
