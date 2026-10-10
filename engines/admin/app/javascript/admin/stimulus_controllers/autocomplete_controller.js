import { Controller } from '@hotwired/stimulus'

const MIN_QUERY_LENGTH = 2

export default class extends Controller {
  static targets = [
    'input',
    'results',
  ]

  static values = {
    url: String,
    keepInput: Boolean,
    authorIds: Array
  }

  connect() {
    this.resultsTarget.hidden = true
    this.debounceTimeout = null
  }

  // ACTION
  search(event) {
    const query = event.target.value.trim()

    // Clear selection if input is cleared
    if (query === '') {
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
      const response = await fetch(this.searchUrl(query))
      const entries = await response.json()
      this.displayResults(entries)
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Error fetching autocomplete results:', error)
      this.resultsTarget.hidden = true
    }
  }

  searchUrl(query) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('q', query)
    this.authorIdsValue.forEach(id => {
      if (id === '' || id === null || typeof id === 'undefined') return

      url.searchParams.append('author_ids[]', id)
    })
    return url
  }

  displayResults(entries) {
    // Clear previous results
    this.resultsTarget.innerHTML = ''

    if (entries.length === 0) {
      this.resultsTarget.hidden = true
      return
    }

    // Create result items
    entries.forEach(entry => {
      const item = document.createElement('div')
      item.className = 'list-group-item list-group-item-action'
      item.style.cursor = 'pointer'
      item.textContent = entry.label

      const handleSelection = event => {
        event.preventDefault()
        event.stopPropagation()
        this.selectEntry(entry)
      }
      item.addEventListener('click', handleSelection)
      // touchpad
      item.addEventListener('pointerdown', handleSelection)

      this.resultsTarget.appendChild(item)
    })

    this.resultsTarget.hidden = false
  }

  selectEntry(entry) {
    this.inputTarget.value = this.keepInputValue ? (entry.label || '') : null
    this.resultsTarget.hidden = true
    this.notifySelection(entry)
  }

  notifySelection(entry) {
    this.dispatch('selected', {
      detail: {
        entry
      }
    })
  }

  // ACTION
  handleBlur() {
    // Delay hiding results to allow click events to fire
    setTimeout(() => {
      this.resultsTarget.hidden = true
    }, 200)
  }

  // ACTION
  handleFocus(event) {
    const query = event.target.value.trim()
    if (query.length >= MIN_QUERY_LENGTH)
      this.performSearch(query)
  }
}

