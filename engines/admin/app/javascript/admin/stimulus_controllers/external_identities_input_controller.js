import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'identitiesList',
    'identityTemplate',
  ]

  connect() {
    this.fillInitialIdentities()
  }

  fillInitialIdentities() {
    const currentIdentities = JSON.parse(this.identitiesListTarget.dataset.values)
    currentIdentities.forEach(identity => {
      this.renderIdentity(identity)
    })
  }

  renderIdentity(identity = {}) {
    const template = this.identityTemplateTarget.content.cloneNode(true)
    template.querySelector('[data-name="idInput"]').value = identity.id || null

    const tempWorkbench = document.createElement('tbody')
    tempWorkbench.appendChild(template)
    const index = Math.random().toString(16).substring(2, 8)
    tempWorkbench.innerHTML = tempWorkbench.innerHTML.replaceAll('ENTRY_ID', index)

    const newIdentityEntry = this.identitiesListTarget.appendChild(tempWorkbench.firstElementChild)
    newIdentityEntry.querySelector('[data-name="externalResource"]').value = identity.external_resource || ''
    newIdentityEntry.querySelector('[data-name="externalId"]').value = identity.external_id || null
  }

  // ACTION
  onClickAddIdentity() {
    this.renderIdentity()
  }

  // ACTION
  onClickDeleteIdentity(event) {
    const identity = event.target.closest('[data-name="identity"]')
    if (!identity) return

    identity.querySelector('[data-name="destroyInput"]').value = true
    identity.hidden = true
  }
}
