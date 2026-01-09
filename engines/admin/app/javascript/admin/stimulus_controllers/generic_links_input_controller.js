import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'linksList',
    'linkTemplate',
  ]

  connect() {
    this.fillInitialLinks()
  }

  fillInitialLinks() {
    const currentLinks = JSON.parse(this.linksListTarget.dataset.values)
    currentLinks.forEach(link => {
      this.renderLink(link)
    })
  }

  renderLink(link = {}) {
    const template = this.linkTemplateTarget.content.cloneNode(true)
    template.querySelector('[data-name="idInput"]').value = link.id || null

    const tempWorkbench = document.createElement('tbody')
    tempWorkbench.appendChild(template)
    const index = Math.random().toString(16).substring(2, 8)
    tempWorkbench.innerHTML = tempWorkbench.innerHTML.replaceAll('ENTRY_ID', index)

    const newLinkEntry = this.linksListTarget.appendChild(tempWorkbench.firstElementChild)
    newLinkEntry.querySelector('[data-name="name"]').value = link.name || null
    newLinkEntry.querySelector('[data-name="url"]').value = link.url || null
  }

  // ACTION
  onClickAddLink() {
    this.renderLink()
  }

  // ACTION
  onClickDeleteLink(event) {
    const link = event.target.closest('[data-name="link"]')
    if (!link) return

    link.querySelector('[data-name="destroyInput"]').value = true
    link.hidden = true
  }
}
