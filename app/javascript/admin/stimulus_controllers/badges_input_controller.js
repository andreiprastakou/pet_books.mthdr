import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'addButton',
    'badges',
    'badgeNameInput',
    'badgeNewNameInput',
    'badgeTemplate',
  ]

  connect() {
    this.fillInitialBadges()
    this.updateBadgeAddButton()
  }

  fillInitialBadges() {
    const names = JSON.parse(this.badgesTarget.dataset.initialValues)
    const oldNames = JSON.parse(this.badgesTarget.dataset.oldValue)
    names.forEach(name => {
      this.addNewBadge(name, { new: !oldNames.includes(name) })
    })
    oldNames.forEach(name => {
      if (names.includes(name)) return

      const badge = this.addNewBadge(name)
      this.markBadgeAsRemoved(badge)
    })
  }

  updateBadgeAddButton() {
    const name = this.badgeNewNameInputTarget.value.trim()
    if (name)
      this.addButtonTarget.disabled = false
    else
      this.addButtonTarget.disabled = true
  }

  onAddClicked(event) {
    event.preventDefault()
    const names = this.badgeNewNameInputTarget.value.trim()
    this.badgeNewNameInputTarget.value = ''
    this.badgeNewNameInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    this.addNames(names)
  }

  addNames(namesString) {
    const currentValues = this.badgeNameInputTargets.map(badgeNameInput => badgeNameInput.value)
    const namesToAdd = namesString.split(',').map(name => name.trim().replace(/\.$/gu, '')).
      filter(name => !currentValues.includes(name))
    namesToAdd.forEach(name => {
      this.addNewBadge(name.trim(), { new: true })
    })
  }

  addNewBadge(name, options = { new: false }) {
    if (!name) return null

    const badgeTemplate = this.badgeTemplateTarget.content.cloneNode(true)
    badgeTemplate.querySelector('[data-name="name"]').textContent = name
    badgeTemplate.querySelector('[data-name="badgeNameInput"]').value = name
    const badge = badgeTemplate.querySelector('[data-name="badge"]')
    this.badgesTarget.appendChild(badgeTemplate)
    if (options.new) {
      badge.classList.add('new')
      badge.dataset.newBadge = true
    }
    return badge
  }

  deleteBadge(event) {
    const badge = event.target.closest('[data-name="badge"]')
    if (!badge) return

    if (badge.dataset.newBadge)
      badge.remove()
    else
      this.markBadgeAsRemoved(badge)
  }

  markBadgeAsRemoved(badge) {
    badge.classList.add('removed')
    badge.querySelector('[data-name="badgeNameInput"]').disabled = true
  }

  restoreBadge(event) {
    const badge = event.target.closest('[data-name="badge"]')
    if (!badge) return

    badge.classList.remove('removed')
    badge.querySelector('[data-name="badgeNameInput"]').disabled = false
  }

  // Callbacks

  onNamesAdded(event) {
    const { names } = event.detail
    this.addNames(names)
  }
}
