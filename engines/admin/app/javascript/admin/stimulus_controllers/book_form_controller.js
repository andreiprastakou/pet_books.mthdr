import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'goodreadsQueryLink',
    'genreSelect',
    'literaryFormInput',
    'oldValueViewTemplate',
    'submitButton',
    'descriptionTextInput',
    'descriptionSourceLabelInput',
    'titleInput',
    'wikiQueryLink',
    'collectedWorksSection',
    'collectedWorksInput',
    'collectedWorksAutocomplete',
  ]

  connect() {
    this.currentAuthors = []
    this.toggleCollectedWorks()
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
    this.literaryFormInputTarget.value = form
    this.toggleCollectedWorks()

    this.submitButtonTarget.scrollIntoView()
  }

  // ACTION
  onLiteraryFormChanged() {
    this.toggleCollectedWorks()
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
      this.syncCollectedWorksAuthorIds()
    }
    if (association === 'collectedWorks')
      this.toggleCollectedWorks()
  }

  toggleCollectedWorks() {
    if (!this.hasCollectedWorksSectionTarget || !this.hasLiteraryFormInputTarget) return

    const isCollection = this.literaryFormInputTarget.value === 'collection'
    this.collectedWorksSectionTarget.hidden = !isCollection && !this.collectedWorksPresent()
    if (this.hasCollectedWorksInputTarget)
      this.collectedWorksInputTarget.hidden = !isCollection
  }

  collectedWorksPresent() {
    const badges = this.collectedWorksSectionTarget.querySelector('[data-association-input-target="badges"]')
    if (!badges) return false
    if (badges.querySelector('[data-name="badge"]')) return true

    return JSON.parse(badges.dataset.values || '[]').length > 0
  }

  syncCollectedWorksAuthorIds() {
    if (!this.hasCollectedWorksAutocompleteTarget) return

    const ids = this.currentAuthors.map(author => author.id).filter(id => id)
    const element = this.collectedWorksAutocompleteTarget
    const controller = this.application.getControllerForElementAndIdentifier(element, 'autocomplete')
    if (controller)
      controller.authorIdsValue = ids
    else
      element.dataset.autocompleteAuthorIdsValue = JSON.stringify(ids)
  }
}
