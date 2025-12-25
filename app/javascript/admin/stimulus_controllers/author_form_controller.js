import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'fullnameInput',
    'referenceQueryLink',
    'photoQueryLink',
  ]

  connect() {
    this.syncName()
  }

  syncName() {
    const fullname = this.fullnameInputTarget.value.trim()
    this.updateReferenceQuery(fullname)
    this.updatePhotoQuery(fullname)
  }

  updateReferenceQuery(fullname) {
    if (fullname) {
      const href = this.referenceQueryLinkTarget.getAttribute('data-href-scaffold')
      const queryUrl = href.replace('NAME', encodeURI(fullname))
      this.referenceQueryLinkTarget.setAttribute('href', queryUrl)
    } else
      this.referenceQueryLinkTarget.removeAttribute('href')
  }

  updatePhotoQuery(fullname) {
    if (fullname) {
      const href = this.photoQueryLinkTarget.getAttribute('data-href-scaffold')
      const queryUrl = href.replace('NAME', encodeURI(fullname))
      this.photoQueryLinkTarget.setAttribute('href', queryUrl)
    } else
      this.photoQueryLinkTarget.removeAttribute('href')
  }
}
