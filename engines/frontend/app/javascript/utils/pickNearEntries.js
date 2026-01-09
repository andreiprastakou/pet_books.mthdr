import { compact, isEmpty, min } from 'lodash'

const pickNearEntries = (entries, middle, { lengthBefore = 1, lengthAfter = 1, looped = true } = {}) => {
  const middleIndex = entries.indexOf(middle)

  if (isEmpty(entries)) return []

  const indexes = []
  const leftOffset = min([Math.floor((entries.length - 1) / 2), lengthBefore])
  const rightOffset = min([Math.floor(entries.length / 2), lengthAfter])
  iterateIndexesNear(entries, middleIndex - leftOffset, middleIndex + rightOffset, index => {
    const workingIndex = looped ? indexToLoopedIndex(index, entries) : index
    if (!indexes.includes(workingIndex)) indexes.push(workingIndex)
  })

  return compact(indexes.map(index => entries[index]))
}

const iterateIndexesNear = (entries, fromIndex, toIndex, callback) => {
  let currentIndex = fromIndex
  while (currentIndex <= toIndex) {
    callback(currentIndex)

    currentIndex += 1
  }
}

const indexToLoopedIndex = (index, entries) => {
  const limit = entries.length
  return ((index % limit) + limit) % limit
}

export { pickNearEntries }
