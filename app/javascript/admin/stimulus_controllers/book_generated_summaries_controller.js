import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'datFilledInput',
    'summaryVerifiedInput',
  ]

  onPick(event) {
    // eslint-disable-next-line no-unused-vars
    const { verificationUrl: _, ...bookParams } = event.params
    this.datFilledInputTarget.value = true
    this.summaryVerifiedInputTarget.value = true
    this.dispatch('pickSummary', { detail: bookParams })
  }

  onAddAllTags(event) {
    this.dispatch('addTags', { detail: event.params })
  }
}
