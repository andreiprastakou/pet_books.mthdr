import { Controller } from '@hotwired/stimulus'

const MIN_QUERY_LENGTH = 2

export default class extends Controller {
  static targets = [
    'input',
    'results',
  ]

  static values = {
    url: String
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
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      const entries = await response.json()
      this.displayResults(entries)
    } catch (error) {
      this.resultsTarget.hidden = true
    }
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
    this.inputTarget.value = null
    this.resultsTarget.hidden = true
    this.notifySelection(entry)
  }

  notifySelection(entry) {
    this.dispatch('selected', {
      detail: {
        entry: entry
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

