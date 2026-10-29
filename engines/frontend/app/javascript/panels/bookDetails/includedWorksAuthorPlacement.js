import { FORMAT_COLLECTION } from 'utils/coverPalettes'

export const includedWorkIdsFor = book => (
  book?.format === FORMAT_COLLECTION && book.collectedWorkIds?.length > 0
    ? book.collectedWorkIds
    : null
)

const authorSetKey = authorIds => [...(authorIds || [])].sort((a, b) => a - b).join(',')

// 'heading' = shared authors → show at top, omit in list
// 'entries' = mixed authors → omit at top, keep in list
// null = not a collection / works not ready yet → keep the usual heading
export const includedWorksAuthorPlacement = (workIds, booksIndex) => {
  if (!workIds?.length) return null

  const works = workIds.map(id => booksIndex[id])
  if (works.some(work => !work)) return null

  const firstKey = authorSetKey(works[0].authorIds)
  const shared = works.every(work => authorSetKey(work.authorIds) === firstKey)

  return shared ? 'heading' : 'entries'
}
