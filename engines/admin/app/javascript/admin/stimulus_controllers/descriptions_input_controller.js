import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'descriptionsList',
    'descriptionTemplate',
  ]

  connect() {
    this.fillInitialDescriptions()
  }

  fillInitialDescriptions() {
    const currentDescriptions = JSON.parse(this.descriptionsListTarget.dataset.values)
    currentDescriptions.forEach(description => {
      this.renderDescription(description)
    })
  }

  renderDescription(description = {}) {
    const template = this.descriptionTemplateTarget.content.cloneNode(true)
    const priority = description.priority == null ? this.nextPriority() : description.priority

    const tempWorkbench = document.createElement('div')
    tempWorkbench.appendChild(template)
    const index = Math.random().toString(16).substring(2, 8)
    tempWorkbench.innerHTML = tempWorkbench.innerHTML.replaceAll('ENTRY_ID', index)

    const newEntry = this.descriptionsListTarget.appendChild(tempWorkbench.firstElementChild)
    newEntry.querySelector('[data-name="idInput"]').value = description.id || ''
    newEntry.querySelector('[data-name="textInput"]').value = description.text || ''
    newEntry.querySelector('[data-name="sourceLabelInput"]').value = description.source_label || ''
    newEntry.querySelector('[data-name="priorityInput"]').value = priority

    this.fillSourceFields(newEntry, description)
  }

  fillSourceFields(entry, description) {
    const sourceFields = entry.querySelector('[data-name="sourceFields"]')
    const sourceType = description.source_type
    const sourceId = description.source_id
    if (!sourceType || sourceId == null || sourceId === '') {
      sourceFields.hidden = true
      return
    }

    sourceFields.hidden = false
    entry.querySelector('[data-name="sourceTypeInput"]').value = sourceType
    entry.querySelector('[data-name="sourceIdInput"]').value = sourceId
  }

  nextPriority() {
    const priorities = this.visibleDescriptions().map(entry => {
      return Number(entry.querySelector('[data-name="priorityInput"]').value) || 0
    })
    if (priorities.length === 0) return 0

    return Math.max(...priorities) + 1
  }

  visibleDescriptions() {
    return Array.from(
      this.descriptionsListTarget.querySelectorAll('[data-name="description"]:not([hidden])')
    )
  }

  swapPriorities(firstEntry, secondEntry) {
    const firstPriority = firstEntry.querySelector('[data-name="priorityInput"]')
    const secondPriority = secondEntry.querySelector('[data-name="priorityInput"]')
    const previousValue = firstPriority.value
    firstPriority.value = secondPriority.value
    secondPriority.value = previousValue
  }

  // ACTION
  onClickAddDescription() {
    this.renderDescription()
  }

  // ACTION
  onClickRemoveDescription(event) {
    const description = event.target.closest('[data-name="description"]')
    if (!description) return

    description.querySelector('[data-name="destroyInput"]').value = true
    description.hidden = true
  }

  // ACTION
  onClickMoveUp(event) {
    const description = event.target.closest('[data-name="description"]')
    if (!description) return

    const visibles = this.visibleDescriptions()
    const index = visibles.indexOf(description)
    if (index <= 0) return

    const neighbour = visibles[index - 1]
    this.swapPriorities(description, neighbour)
    this.descriptionsListTarget.insertBefore(description, neighbour)
  }

  // ACTION
  onClickMoveDown(event) {
    const description = event.target.closest('[data-name="description"]')
    if (!description) return

    const visibles = this.visibleDescriptions()
    const index = visibles.indexOf(description)
    if (index < 0 || index >= visibles.length - 1) return

    const neighbour = visibles[index + 1]
    this.swapPriorities(description, neighbour)
    this.descriptionsListTarget.insertBefore(neighbour, description)
  }
}
