import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'authorNameColorInput',
    'authorNameFontInput',
    'coverImageInput',
    'nameInput',
    'previewContainer',
    'previewTemplate',
    'titleColorInput',
    'titleFontInput',
  ]

  connect() {
    this.resetPreview()
  }

  resetPreview() {
    const preview = this.buildNewPreview()
    this.previewContainerTarget.innerHTML = null
    this.previewContainerTarget.appendChild(preview)
  }

  buildNewPreview() {
    const canvas = this.previewTemplateTarget.content.cloneNode(true)

    canvas.querySelector('[data-name="container"]').dataset.coverImage = this.coverImageInputTarget.value

    const titleElement = canvas.querySelector('[data-name="title"]')
    titleElement.textContent = this.nameInputTarget.value
    titleElement.dataset.textColor = this.titleColorInputTarget.value
    titleElement.dataset.font = this.titleFontInputTarget.value

    const authorElement = canvas.querySelector('[data-name="author"]')
    authorElement.dataset.textColor = this.authorNameColorInputTarget.value
    authorElement.dataset.font = this.authorNameFontInputTarget.value
    return canvas
  }
}
