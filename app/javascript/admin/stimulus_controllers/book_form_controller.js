import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'authorName',
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
    const author = this.authorNameTarget.value.trim() || 'author'
    if (title) {
      const query = { q: `goodreads book ${title} by ${author}` }
      this.goodreadsQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.goodreadsQueryLinkTarget.removeAttribute('href')
  }

  syncWikiQuery() {
    if (!this.hasWikiQueryLinkTarget) return

    const title = this.titleInputTarget.value.trim()
    const author = this.authorNameTarget.value.trim() || 'author'
    if (title) {
      const query = { q: `wikipedia book ${title} by ${author}` }
      this.wikiQueryLinkTarget.href = `http://google.com/search?${new URLSearchParams(query)}`
    } else
      this.wikiQueryLinkTarget.removeAttribute('href')
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
}
