export const GRID_ROW_SIZE = 4

export const keyType = key => {
  if (key === 'Enter') return 'enter'
  if (key === 'ArrowLeft' || key === 'Left') return 'left'
  if (key === 'ArrowRight' || key === 'Right') return 'right'
  if (key === 'ArrowUp' || key === 'Up') return 'up'
  if (key === 'ArrowDown' || key === 'Down') return 'down'
  if (key === 'PageUp') return 'pageUp'
  if (key === 'PageDown') return 'pageDown'
  return null
}

export const isBlocked = ({ type, index, lastIndex, page, lastPage, rowSize = GRID_ROW_SIZE }) => (
  (type === 'left' && index % rowSize === 0) ||
    (type === 'right' && (index % rowSize === rowSize - 1 || index === lastIndex)) ||
    (type === 'pageUp' && page <= 1) ||
    (type === 'pageDown' && page >= lastPage)
)

export const targetSelection = ({
  type, index, lastIndex, page, perPage, totalCount, rowSize = GRID_ROW_SIZE,
}) => {
  if (type === 'left') return { index: index - 1, page }
  if (type === 'right') return { index: index + 1, page }

  const currentGlobalIndex = ((page - 1) * perPage) + index
  const targetGlobalIndex = currentGlobalIndex + (type === 'up' ? -rowSize : rowSize)

  if (targetGlobalIndex < 0)
    return { index: 0, page }

  if (targetGlobalIndex >= totalCount)
    return { index: lastIndex, page }

  return {
    index: targetGlobalIndex % perPage,
    page: Math.floor(targetGlobalIndex / perPage) + 1,
  }
}

export const pageSelection = ({ type, index, page, perPage, totalCount }) => {
  const nextPage = page + (type === 'pageDown' ? 1 : -1)
  const nextLength = Math.min(perPage, totalCount - ((nextPage - 1) * perPage))
  return { index: Math.min(index, nextLength - 1), page: nextPage }
}
