import { FORMAT_COLLECTION } from 'utils/coverPalettes'

export const collectionIdsByWorkId = (bookIds, booksIndex) => {
  const map = new Map()
  bookIds.forEach(collectionId => {
    const entry = booksIndex[collectionId]
    if (!entry || entry.format !== FORMAT_COLLECTION) return

    const workIds = entry.collectedWorkIds || []
    workIds.forEach(workId => {
      const collectionIds = map.get(workId) || []
      collectionIds.push(collectionId)
      map.set(workId, collectionIds)
    })
  })
  return map
}

export const displayedWorksCount = (bookIds, booksTotal, booksIndex) => {
  const collectionCount = bookIds.filter(id => booksIndex[id]?.format === FORMAT_COLLECTION).length
  return Math.max(0, booksTotal - collectionCount)
}

export const hiddenSelectionFor = (collectionsByWorkId, bookId) => {
  const collectionIds = collectionsByWorkId.get(bookId)
  if (!collectionIds || collectionIds.length === 0) return null

  return { 'book_id': collectionIds[0] }
}

export const compactStackFromUrl = url => url.queryParameter('compact_stack') !== '0'
