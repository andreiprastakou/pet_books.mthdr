import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'booksList',
    'bookEntry',
    'bookTemplate',
    'notices',
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

    if (this.bookAlreadyListed(entry.id, row)) {
      this.showError(this.duplicateBookMessage(entry))
      return
    }

    const rendered = await this.fetchBookRow(entry.id, this.rowIndex(row))
    if (!rendered) return

    if (this.bookAlreadyListed(entry.id, row)) {
      this.showError(this.duplicateBookMessage(entry))
      return
    }

    this.clearError()
    this.nullifyRedundantOriginalTitle(rendered)
    row.replaceWith(rendered)
  }

  bookAlreadyListed(bookId, currentRow) {
    const id = String(bookId)
    return [...this.element.querySelectorAll('input[name$="[id]"]')].some(input => {
      if (!input.value || input.value !== id) return false

      const row = input.closest('[data-name="book-row"]')
      return row && row !== currentRow
    })
  }

  duplicateBookMessage(entry) {
    return entry.label ? `${entry.label} is already in the list.` : 'This book is already in the list.'
  }

  showError(message) {
    this.noticesTarget.replaceChildren()
    const alert = document.createElement('div')
    alert.className = 'alert alert-danger alert-dismissible fade show'
    alert.setAttribute('role', 'alert')
    alert.append(document.createTextNode(message))

    const close = document.createElement('button')
    close.type = 'button'
    close.className = 'btn-close'
    close.dataset.bsDismiss = 'alert'
    alert.append(close)
    this.noticesTarget.append(alert)
  }

  clearError() {
    this.noticesTarget.replaceChildren()
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
