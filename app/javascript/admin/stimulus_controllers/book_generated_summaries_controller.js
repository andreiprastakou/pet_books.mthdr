import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'dataFilledInput',
  ]

  onPick(event) {
    // eslint-disable-next-line no-unused-vars
    const { verificationUrl: _a, ...bookParams } = event.params
    this.dataFilledInputTarget.value = true
    this.dispatch('pickSummary', { detail: bookParams })
  }

  onAddAllTags(event) {
    this.dispatch('addTags', { detail: event.params })
  }
}
