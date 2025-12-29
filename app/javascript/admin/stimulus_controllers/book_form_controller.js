import { Controller } from '@hotwired/stimulus'
import { ThemeConsumer } from 'react-bootstrap/esm/ThemeProvider'

export default class extends Controller {
  static targets = [
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
    this.currentAuthors = []
  }

  // ACTION
  onSrcClearClicked() {
    this.summarySrcInputTarget.value = ''
    this.summarySrcInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
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
    this.summaryInputTarget.value = summary
    this.summarySrcInputTarget.value = src
    this.literaryFormInputTarget.value = form
    this.summarySrcInputTarget.dispatchEvent(new Event('input', { bubbles: true }))

    this.submitButtonTarget.scrollIntoView()
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
