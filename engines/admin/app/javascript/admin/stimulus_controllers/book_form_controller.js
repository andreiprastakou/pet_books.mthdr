import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'goodreadsQueryLink',
    'genreSelect',
    'literaryFormInput',
    'literaryFormWarning',
    'oldValueViewTemplate',
    'submitButton',
    'descriptionTextInput',
    'descriptionSourceLabelInput',
    'titleInput',
    'wikiQueryLink',
  ]

  connect() {
    this.currentAuthors = []
  }

  // ACTION
  syncQueries() {
    this.syncGoodreadsQuery()
    this.syncWikiQuery()
  }

  syncGoodreadsQuery() {
    if (!this.hasGoodreadsQueryLinkTarget) return

    const title = this.titleInputTarget.value.trim()
    const author = this.authorNames().join(', ')
    if (title) {
      const query = { q: `goodreads book ${title} by ${author}` }
      this.goodreadsQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.goodreadsQueryLinkTarget.removeAttribute('href')
  }

  syncWikiQuery() {
    if (!this.hasWikiQueryLinkTarget) return

    const title = this.titleInputTarget.value.trim()
    const author = this.authorNames().join(', ')
    if (title) {
      const query = { q: `wikipedia book ${title} by ${author}` }
      this.wikiQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.wikiQueryLinkTarget.removeAttribute('href')
  }

  authorNames() {
    return this.currentAuthors.map(author => author.label)
  }

  // ACTION
  onSummaryPicked(event) {
    const { summary, src, genres, themes, form } = event.detail
    this.dispatch('addTags', { detail: { names: themes } })
    this.dispatch('addGenres', { detail: { names: genres } })
    this.descriptionTextInputTarget.value = summary
    this.descriptionSourceLabelInputTarget.value = src
    this.applyLiteraryForm(form)

    this.submitButtonTarget.scrollIntoView()
  }

  applyLiteraryForm(form) {
    const input = this.literaryFormInputTarget
    const raw = (form ?? '').trim()
    const option = this.matchingLiteraryFormOption(raw)
    input.value = option ? option.value : ''
    input.dispatchEvent(new Event('input', { bubbles: true }))
    this.renderSuggestedLiteraryFormWarning(option || raw === '' ? null : raw)
  }

  matchingLiteraryFormOption(raw) {
    if (!raw) return null

    const needle = raw.toLowerCase()
    return Array.from(this.literaryFormInputTarget.options).find(option =>
      option.value === raw || option.value === needle || option.text.trim().toLowerCase() === needle
    ) || null
  }

  renderSuggestedLiteraryFormWarning(value) {
    if (!this.hasLiteraryFormWarningTarget) return

    this.literaryFormWarningTarget.querySelectorAll('[data-suggested-literary-form]').forEach(node => node.remove())
    if (!value) return

    const node = document.createElement('div')
    node.className = 'form-text text-warning'
    node.dataset.suggestedLiteraryForm = 'true'
    node.textContent = `Current value '${value}' will be replaced!`
    this.literaryFormWarningTarget.appendChild(node)
  }

  // ACTION
  onTagsAdded(event) {
    const { themes } = event.detail
    this.dispatch('addTags', { detail: { names: themes } })
  }

  // ACTION
  onAssociationChanged(event) {
    const { association, entries } = event.detail
    if (association === 'authors') {
      this.currentAuthors = entries
      this.syncQueries()
    }
  }
}
