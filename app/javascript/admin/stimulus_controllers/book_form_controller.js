import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'authorSelect',
    'goodreadsQueryLink',
    'genreSelect',
    'literaryFormInput',
    'oldValueViewTemplate',
    'submitButton',
    'summaryInput',
    'summarySrcInput',
    'titleInput',
    'wikiQueryLink',
  ]

  connect() {
    this.syncGoodreadsQuery()

    this.syncWikiQuery()

    this.initializeChangeIndicators()
  }

  onSrcClearClicked() {
    this.summarySrcInputTarget.value = ''
    this.summarySrcInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  //
  // GOODREADS
  //

  syncGoodreadsQuery() {
    if (!this.hasGoodreadsQueryLinkTarget) return

    const title = this.titleInputTarget.value.trim()
    const author = this.authorSelectTarget.selectedOptions[0]?.text.trim() || 'author'
    if (title) {
      const query = { q: `goodreads book ${title} by ${author}` }
      this.goodreadsQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.goodreadsQueryLinkTarget.removeAttribute('href')
  }

  //
  // WIKI
  //

  syncWikiQuery() {
    if (!this.hasWikiQueryLinkTarget) return

    const title = this.titleInputTarget.value.trim()
    const author = this.authorSelectTarget.selectedOptions[0]?.text.trim() || 'author'
    if (title) {
      const query = { q: `wikipedia book ${title} by ${author}` }
      this.wikiQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.wikiQueryLinkTarget.removeAttribute('href')
  }

  //
  // CHANGE INDICATORS
  //

  initializeChangeIndicators() {
    this.element.querySelectorAll('[data-behaviour="indicateChanges"]').forEach(element => {
      const presetOldValue = element.dataset.oldValue
      if (presetOldValue)
        this.handleInpicatedChange(element)
      else
        element.dataset.oldValue = element.value.trim()

      element.addEventListener('input', event => this.handleInpicatedChange.bind(this)(event.target))
    })
  }

  handleInpicatedChange(inputElement) {
    const currentValue = inputElement.value.trim()
    const { oldValue } = inputElement.dataset

    if (currentValue === oldValue)
      this.hideOldValue(inputElement)
    else
      this.showOldValue(inputElement, oldValue)
  }

  showOldValue(inputElement, oldValue) {
    let oldValueView = inputElement.parentElement.querySelector('[data-name="oldValueDisplay"]')
    if (!oldValueView) {
      oldValueView = this.oldValueViewTemplateTarget.content.cloneNode(true)
      let oldValueText = oldValue
      if (inputElement.type === 'select-one') {
        const option = Array.from(inputElement.options).find(opt => opt.value === oldValue)
        oldValueText = option ? option.text : oldValue
      }
      oldValueView.querySelector('[data-name="oldValue"]').textContent = oldValueText
      inputElement.parentElement.appendChild(oldValueView)
    }
  }

  hideOldValue(inputElement) {
    const oldValueView = inputElement.parentElement.querySelector('[data-name="oldValueDisplay"]')
    if (oldValueView)
      oldValueView.remove()
  }

  resetOldValue(event) {
    const inputElement = event.target.parentElement.parentElement.querySelector('[data-behaviour="indicateChanges"]')
    const oldValue = inputElement.dataset.oldValue.trim()
    inputElement.value = oldValue
    inputElement.dispatchEvent(new Event('input', { bubbles: true }))
  }

  // Callbacks

  onSummaryPicked(event) {
    const { summary, src, genres, themes, form } = event.detail
    this.dispatch('addTags', { detail: { names: themes } })
    this.dispatch('addGenres', { detail: { names: genres } })
    this.summaryInputTarget.value = summary
    this.summarySrcInputTarget.value = src
    this.literaryFormInputTarget.value = form
    this.summarySrcInputTarget.dispatchEvent(new Event('input', { bubbles: true }))

    this.submitButtonTarget.scrollIntoView()
  }

  onTagsAdded(event) {
    const { themes } = event.detail
    this.dispatch('addTags', { detail: { names: themes } })
  }
}
