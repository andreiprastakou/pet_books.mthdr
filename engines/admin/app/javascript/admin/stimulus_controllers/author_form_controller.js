import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'fullnameInput',
    'wikiQueryLink',
    'photoQueryLink'
  ]

  connect() {
    this.syncName()
  }

  syncName() {
    const fullname = this.fullnameInputTarget.value.trim()
    this.updateWikiQuery(fullname)
    this.updatePhotoQuery(fullname)
  }

  updateWikiQuery(fullname) {
    if (fullname) {
      const href = this.wikiQueryLinkTarget.getAttribute('data-href-scaffold')
      const queryUrl = href.replace('NAME', encodeURI(fullname))
      this.wikiQueryLinkTarget.setAttribute('href', queryUrl)
    } else
      this.wikiQueryLinkTarget.removeAttribute('href')
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
