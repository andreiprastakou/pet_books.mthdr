import { Controller } from '@hotwired/stimulus'

// Keeps a hidden id field in sync when an autocomplete entry is selected.
// Submit stays enabled for a selected id or free-text input value.
export default class extends Controller {
  static targets = ['hidden', 'input', 'submit']

  connect() {
    this.syncSubmit()
  }

  onSelected({ detail: { entry } }) {
    if (this.hasHiddenTarget)
      this.hiddenTarget.value = entry.id || ''
    if (this.hasInputTarget && entry.label)
      this.inputTarget.value = entry.label
    this.syncSubmit()
  }

  onInput() {
    if (this.hasHiddenTarget)
      this.hiddenTarget.value = ''
    this.syncSubmit()
  }

  syncSubmit() {
    if (!this.hasSubmitTarget)
      return

    if (this.submitTarget.dataset.forceDisabled === 'true') {
      this.submitTarget.disabled = true
      return
    }

    const hasId = this.hasHiddenTarget && this.hiddenTarget.value !== ''
    const hasText = this.hasInputTarget && this.inputTarget.value.trim() !== ''
    this.submitTarget.disabled = !(hasId || hasText)
  }
}
