import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'booksList',
    'bookEntry',
    'bookTemplate',
  ]

  connect() {
    this.nullifyRedundantOriginalTitles()
  }

  nullifyRedundantOriginalTitles() {
    this.bookEntryTargets.forEach(bookEntry => {
      const title = bookEntry.querySelector('[data-name="title"]')
      const originalTitle = bookEntry.querySelector('[data-name="original_title"]')
      if (title.value === originalTitle.value)
        originalTitle.value = null
    })
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
}
