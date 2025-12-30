import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'badges',
    'badgeValueInput',
    'badgeTemplate',
  ]

  static values = {
    association: String
  }

  connect() {
    this.fillInitialBadges()
  }

  entryExistsInArray(entry, array) {
    return array.some(item => item.id === entry.id && item.label === entry.label)
  }

  fillInitialBadges() {
    const currentEntries = JSON.parse(this.badgesTarget.dataset.values)
    const oldEntries = JSON.parse(this.badgesTarget.dataset.oldValues)
    this.currentEntries = [...currentEntries]
    currentEntries.forEach(entry => {
      this.renderBadge(entry, { new: !this.entryExistsInArray(entry, oldEntries) })
    })
    oldEntries.forEach(entry => {
      if (this.entryExistsInArray(entry, currentEntries)) return

      const badge = this.renderBadge(entry)
      this.markBadgeAsRemoved(badge)
    })
    this.notifyChanges()
  }

  renderBadge(entry, options = { new: false }) {
    const badgeTemplate = this.badgeTemplateTarget.content.cloneNode(true)
    badgeTemplate.querySelector('[data-name="label"]').textContent = entry.label
    badgeTemplate.querySelector('[data-name="badgeValueInput"]').value = entry.id
    const badge = badgeTemplate.querySelector('[data-name="badge"]')
    badge.title = `${entry.label} (ID=${entry.id})`
    this.badgesTarget.appendChild(badgeTemplate)
    if (options.new) {
      badge.classList.add('new')
      badge.dataset.newBadge = true
    }
    return badge
  }

  // ACTION
  onEntrySelected(event) {
    const { entry } = event.detail
    this.addEntry(entry)
  }

  addEntry(entry) {
    let present = false
    this.badgeValueInputTargets.forEach(input => {
      if (String(input.value) === String(entry.id))
        present = true
    })
    if (present) return

    this.renderBadge(entry, { new: true })
    this.currentEntries.push(entry)
    this.notifyChanges()
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

    const entry = this.getEntryFromBadge(badge)
    this.currentEntries = this.currentEntries.filter(e => e.id !== entry.id || e.label !== entry.label)
    this.notifyChanges()
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
    const entry = this.getEntryFromBadge(badge)
    this.currentEntries.push(entry)
    this.notifyChanges()
  }

  getEntryFromBadge(badge) {
    const labelElement = badge.querySelector('[data-name="label"]')
    const valueInput = badge.querySelector('[data-name="badgeValueInput"]')
    return {
      id: parseInt(valueInput.value) || null,
      label: labelElement.textContent.trim()
    }
  }

  notifyChanges() {
    if (!this.hasAssociationValue) return

    this.dispatch('association-changed', {
      detail: {
        association: this.associationValue,
        entries: this.currentEntries
      }
    })
  }
}
