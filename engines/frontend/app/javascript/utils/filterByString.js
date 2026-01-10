export const filterByString = (entries, attributeName, query) => {
  if (!query || query.length < 1) return entries

  return entries.filter(entry => entry[attributeName].toUpperCase().includes(query.toUpperCase()))
}
