import { first } from 'lodash'
import shuffle from 'knuth-shuffle-seeded'
import { pickNearEntries } from 'utils/pickNearEntries'

import { selectCurrentBookId, selectSeed } from 'store/axis/selectors'
import {
  selectBooksRefsByYear,
  selectCurrentBookRef
} from 'store/books/selectors'

const localState = state => state.booksListYearly

export const selectShuffledBooksOfYear = year => state =>
  shuffle(selectBooksRefsByYear(year)(state), selectSeed()(state))

export const selectBookIdsByYear = year => state => selectShuffledBooksOfYear(year)(state).map(book => book.id)

export const selectBookShiftDirectionHorizontal = () => state => localState(state).bookShiftDirectionHorizontal

export const selectCurrentYear = () => state => selectCurrentBookRef()(state)?.year

export const selectYearCurrentBookId = year => state => localState(state).bookIdsCurrentInYear[year]

export const selectYears = () => state => localState(state).years.slice()

export const selectYearsReversed = () => state => selectYears()(state).reverse()

export const selectBookIdsToDisplay = () => state => {
  const years = selectYearsToDisplay()(state)
  return years.flatMap(year =>
    selectDisplayedBookIdsInYear(year)(state)
  )
}

export const selectYearsToDisplay = () => state => {
  const currentBookRef = selectCurrentBookRef()(state)
  if (!currentBookRef) return []

  const centerYear = currentBookRef.year
  return pickNearEntries(selectYearsReversed()(state), centerYear, { lengthBefore: 1, lengthAfter: 1, looped: false })
}

export const selectDisplayedBookIdsInYear = year => state => {
  const bookIds = selectBookIdsByYear(year)(state)
  const currentBookId = selectCurrentBookId()(state)
  const yearCurrentBookId = selectYearCurrentBookId(year)(state)
  const middleBookId = (bookIds.includes(currentBookId)) ? currentBookId : (yearCurrentBookId || first(bookIds))
  return pickNearEntries(bookIds, middleBookId, { lengthBefore: 3, lengthAfter: 3 })
}

export const selectCurrentFilters = () => state => localState(state).filters
