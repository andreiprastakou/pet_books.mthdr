import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'bookIdInput',
    'booksList',
    'bookTemplate',
    'idInput',
    'roleInput',
  ]

  connect() {
    this.fillInitialBooks()
  }

  fillInitialBooks() {
    const currentBooks = JSON.parse(this.booksListTarget.dataset.values)
    currentBooks.forEach(book => {
      this.renderBook(book)
    })
  }

  renderBook(book) {
    const template = this.bookTemplateTarget.content.cloneNode(true)
    template.querySelector('[data-name="label"]').textContent = book.label
    template.querySelector('[data-name="bookIdInput"]').value = book.book_id
    template.querySelector('[data-name="idInput"]').value = book.id || null

    const tempWorkbench = document.createElement('tbody')
    tempWorkbench.appendChild(template)
    const index = Math.random().toString(16).substring(2, 8)
    tempWorkbench.innerHTML = tempWorkbench.innerHTML.replaceAll('ENTRY_ID', index)

    const newBookEntry = this.booksListTarget.appendChild(tempWorkbench.firstElementChild)
    newBookEntry.querySelector('[data-name="roleInput"]').value = book.role || null
  }

  // ACTION
  onBookSelected(event) {
    const { entry } = event.detail
    // eslint-disable-next-line camelcase
    this.renderBook({ book_id: entry.id, label: entry.label })
  }

  // ACTION
  onClickDeleteBook(event) {
    const book = event.target.closest('[data-name="book"]')
    if (!book) return

    book.querySelector('[data-name="destroyInput"]').value = true
    book.hidden = true
  }
}
