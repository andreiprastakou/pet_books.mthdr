import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'booksList',
    'bookEntry',
    'bookTemplate',
  ]

  static values = {
    batchRowUrl: String,
  }

  connect() {
    this.bookEntryTargets.forEach(bookEntry => this.nullifyRedundantOriginalTitle(bookEntry))
  }

  nullifyRedundantOriginalTitle(bookEntry) {
    const title = bookEntry.querySelector('[data-name="title"]')
    const originalTitle = bookEntry.querySelector('[data-name="original_title"]')
    if (!title || !originalTitle) return
    if (title.value === originalTitle.value)
      originalTitle.value = null
  }

  removeBook(event) {
    const bookRow = event.target.closest('[data-name="book-row"]')
    bookRow.remove()
  }

  onClickAddBook(event) {
    event.preventDefault()
    const booksList = this.booksListTarget
    const bookTemplate = this.bookTemplateTarget
    const newBook = bookTemplate.content.cloneNode(true)
    const tempWorkbench = document.createElement('div')
    tempWorkbench.appendChild(newBook)
    const index = Date.now()
    tempWorkbench.innerHTML = tempWorkbench.innerHTML.replaceAll('ENTRY_INDEX', index)
    booksList.appendChild(tempWorkbench.firstElementChild)
  }

  // ACTION
  async onExistingBookSelected(event) {
    const entry = event.detail?.entry
    const row = event.currentTarget.closest('[data-name="book-row"]')
    if (!entry?.id || !row) return

    const rendered = await this.fetchBookRow(entry.id, this.rowIndex(row))
    if (!rendered) return

    this.nullifyRedundantOriginalTitle(rendered)
    row.replaceWith(rendered)
  }

  async fetchBookRow(bookId, index) {
    const url = new URL(this.batchRowUrlValue.replace('BOOK_ID', bookId), window.location.origin)
    url.searchParams.set('index', index)

    try {
      const response = await fetch(url, { headers: { Accept: 'text/html' } })
      if (!response.ok) return null

      const holder = document.createElement('div')
      holder.innerHTML = (await response.text()).trim()
      return holder.firstElementChild
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Error rendering selected book:', error)
      return null
    }
  }

  rowIndex(row) {
    const named = row.querySelector('[name^="batch["]')
    const match = named?.name.match(/^batch\[(\d+)\]/)
    return match ? match[1] : String(Date.now())
  }
}
