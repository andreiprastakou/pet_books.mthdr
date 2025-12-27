import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'input',
    'oldValueView',
  ]

  connect() {
    const inputElement = this.inputTarget

    this.element.querySelector('[data-name="oldValue"]').textContent = this.evaluateOldValueDisplayed()

    this.toggleOldValueDisplay()

    inputElement.addEventListener('input', () => this.toggleOldValueDisplay.bind(this)())
  }

  evaluateOldValueDisplayed() {
    const inputElement = this.inputTarget
    const oldValue = this.element.dataset.oldValue?.trim()
    if (inputElement.type === 'select-one') {
      const option = Array.from(inputElement.options).find(opt => opt.value === oldValue)
      return option ? option.text : oldValue
    }
    return oldValue
  }

  assignDecoration(oldValue, currentValue) {
    if (oldValue)
      if (currentValue === oldValue)
        this.element.classList.remove('changed')
      else
        this.element.classList.add('changed')
    else
      if (currentValue)
        this.element.classList.add('new')
      else
        this.element.classList.remove('new')
  }

  toggleOldValueDisplay() {
    const inputElement = this.inputTarget
    const currentValue = inputElement.value.trim()
    const { oldValue } = this.element.dataset

    this.assignDecoration(oldValue, currentValue)

    if (currentValue === oldValue || !oldValue)
      this.hideOldValue()
    else
      this.showOldValue()
  }

  showOldValue() {
    this.oldValueViewTarget.hidden = false
  }

  hideOldValue() {
    this.oldValueViewTarget.hidden = true
  }

  // ACTION
  resetOldValue() {
    const inputElement = this.inputTarget
    const oldValue = this.element.dataset.oldValue.trim()
    inputElement.value = oldValue
    inputElement.dispatchEvent(new Event('input', { bubbles: true }))
  }
}
