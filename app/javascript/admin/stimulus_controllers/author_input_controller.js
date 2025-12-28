import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'addButton',
    'badges',
    'badgeValueInput',
    'badgeNewEntryInput',
    'badgeTemplate',
  ]

  connect() {
    this.fillInitialBadges()
    this.updateBadgeAddButton()
  }

  entryExistsInArray(entry, array) {
    return array.some(item => item.id === entry.id && item.label === entry.label)
  }

  fillInitialBadges() {
    const currentEntries = JSON.parse(this.badgesTarget.dataset.values)
    const oldEntries = JSON.parse(this.badgesTarget.dataset.oldValues)
    currentEntries.forEach(entry => {
      console.log(entry)
      console.log('old entry?', this.entryExistsInArray(entry, oldEntries))
      this.renderBadge(entry, { new: !this.entryExistsInArray(entry, oldEntries) })
    })
    oldEntries.forEach(entry => {
      console.log(entry)
      console.log('new entry?', this.entryExistsInArray(entry, currentEntries))
      if (this.entryExistsInArray(entry, currentEntries)) return

      const badge = this.renderBadge(entry)
      this.markBadgeAsRemoved(badge)
    })
  }

  // ACTION
  updateBadgeAddButton() {
    const name = this.badgeNewEntryInputTarget.value.trim()
    if (name)
      this.addButtonTarget.disabled = false
    else
      this.addButtonTarget.disabled = true
  }

  renderBadge(entry, options = { new: false }) {
    const badgeTemplate = this.badgeTemplateTarget.content.cloneNode(true)
    badgeTemplate.querySelector('[data-name="label"]').textContent = entry.label
    badgeTemplate.querySelector('[data-name="badgeValueInput"]').value = entry.id || null
    const badge = badgeTemplate.querySelector('[data-name="badge"]')
    this.badgesTarget.appendChild(badgeTemplate)
    if (options.new) {
      badge.classList.add('new')
      badge.dataset.newBadge = true
    }
    return badge
  }

  // ACTION
  onAddClicked(event) {
    event.preventDefault()
    const entry = { label: this.badgeNewEntryInputTarget.value.trim(), id: this.badgeValueInputTarget.dataset.valueId }
    this.badgeNewEntryInputTarget.value = ''
    this.badgeNewEntryInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    this.addEntry(entry)
  }

  addEntry(entry) {
    var present = false
    this.badgeValueInputTargets.forEach(input => {
      const badge = input.closest('[data-name="badge"]')
      if (input.value === entry.id) {
        this.restoreBadge(badge)
        present = true
      } else {
        this.deleteBadge(badge)
      }
    })
    if (present) return

    this.renderBadge(entry, { new: true })
  }

  // ACTION
  onClickDeleteBadge(event) {
    const badge = event.target.closest('[data-name="badge"]')
    if (!badge) return

    this.deleteBadge(badge)
  }

  deleteBadge(badge) {
    if (badge.dataset.newBadge)
      badge.remove()
    else
      this.markBadgeAsRemoved(badge)
  }

  markBadgeAsRemoved(badge) {
    badge.classList.add('removed')
    badge.querySelector('[data-name="badgeValueInput"]').disabled = true
  }

  // ACTION
  onClickRestoreBadge(event) {
    const badge = event.target.closest('[data-name="badge"]')
    if (!badge) return

    this.restoreBadge(badge)
  }

  restoreBadge(badge) {
    badge.classList.remove('removed')
    badge.querySelector('[data-name="badgeValueInput"]').disabled = false
  }
}
