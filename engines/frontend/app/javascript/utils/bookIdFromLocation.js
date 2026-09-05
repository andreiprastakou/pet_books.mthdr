export const bookIdFromSearch = (search = '') => {
  const raw = new URLSearchParams(search).get('book_id')
  if (raw === null) return null
  const value = parseInt(raw, 10)
  return Number.isNaN(value) ? null : value
}

export const bookIdFromWindowLocation = () => bookIdFromSearch(window.location.search)
