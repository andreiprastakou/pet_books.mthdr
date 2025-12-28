import { Controller } from '@hotwired/stimulus'

const MIN_QUERY_LENGTH = 2

export default class extends Controller {
  static targets = [
    'input',
    'hidden',
    'results',
  ]

  static values = {
    url: String,
    selectedId: Number,
    selectedName: String,
  }

  connect() {
    this.selectedIdValue = this.hiddenTarget.value || null
    if (this.selectedNameValue) {
      this.inputTarget.value = this.selectedNameValue
    }
    this.resultsTarget.hidden = true
    this.debounceTimeout = null
  }

  // ACTION
  search(event) {
    const query = event.target.value.trim()

    // Clear selection if input is cleared
    if (query === '') {
      this.hiddenTarget.value = ''
      this.resultsTarget.hidden = true
      return
    }

    // Debounce the search
    clearTimeout(this.debounceTimeout)
    this.debounceTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    if (query.length < MIN_QUERY_LENGTH) {
      this.resultsTarget.hidden = true
      return
    }

    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      const authors = await response.json()
      this.displayResults(authors)
    } catch (error) {
      console.error('Error searching authors:', error)
      this.resultsTarget.hidden = true
    }
  }

  displayResults(authors) {
    // Clear previous results
    this.resultsTarget.innerHTML = ''

    if (authors.length === 0) {
      this.resultsTarget.hidden = true
      return
    }

    // Create result items
    authors.forEach(author => {
      const item = document.createElement('div')
      item.className = 'list-group-item list-group-item-action'
      item.style.cursor = 'pointer'
      item.textContent = author.fullname
      item.dataset.authorId = author.id
      item.dataset.authorName = author.fullname

      const handleSelection = (event) => {
        event.preventDefault()
        event.stopPropagation()
        this.selectAuthor(author)
      }
      item.addEventListener('click', handleSelection)
      item.addEventListener('pointerdown', handleSelection) // touchpad

      this.resultsTarget.appendChild(item)
    })

    this.resultsTarget.hidden = false
  }

  selectAuthor(author) {
    this.inputTarget.value = author.fullname
    this.hiddenTarget.value = author.id
    this.resultsTarget.hidden = true
    this.selectedIdValue = author.id
    this.selectedNameValue = author.fullname
  }

  // ACTION
  handleBlur(event) {
    // Delay hiding results to allow click events to fire
    setTimeout(() => {
      this.resultsTarget.hidden = true
    }, 200)
  }

  // ACTION
  handleFocus(event) {
    const query = event.target.value.trim()
    if (query.length >= MIN_QUERY_LENGTH) {
      this.performSearch(query)
    }
  }
}

