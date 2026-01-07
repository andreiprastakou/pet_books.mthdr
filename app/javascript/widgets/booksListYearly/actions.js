import { clamp, first, last, pull } from 'lodash'
import { slice } from 'widgets/booksListYearly/slice'
import { pickNearEntries } from 'utils/pickNearEntries'
import apiClient from 'store/books/apiClient'

import { selectCurrentBookId } from 'store/axis/selectors'
import {
  selectBooksIndexEntry,
  selectBooksIndex,
  selectCurrentBookRef,
} from 'store/books/selectors'
import {
  addBook,
  clearBooksRefs,
  fetchMissingBookIndexEntries,
  showBook,
  setCurrentBookDetails,
  setRequestedBookId,
} from 'store/books/actions'
import { selectTagNames } from 'store/tags/selectors'

import {
  selectBookIdsByYear,
  selectBookIdsToDisplay,
  selectShuffledBooksOfYear,
  selectYears,
  selectYearCurrentBookId,
} from 'widgets/booksListYearly/selectors'

import {
  clearState as clearYearsInnerState,
  requestYearRefsLoaded,
} from 'widgets/booksListYearly/refsLoader/actions'

export const {
  addYears,
  clearState: clearListInnerState,
  markBookAsInProcess,
  unmarkBookAsInProcess,
  setBookShiftDirectionHorizontal,
  setCurrentBookForYear,
  setFilters,
  setYears,
} = slice.actions

export const setupBooksListSelection = () => async(dispatch, getState) => {
  const bookId = selectCurrentBookId()(getState())
  if (bookId) {
    const bookRef = await apiClient.getBookRefEntry(bookId)
    dispatch(jumpToYear(bookRef.year))
  } else {
    dispatch(setRequestedBookId(null))
    dispatch(jumpToLatestYear())
  }
}

export const setBookAsCurrentInYear = bookRef => (dispatch, getState) => {
  const state = getState()
  const currentYearsBookId = selectYearCurrentBookId(bookRef.year)(state)
  if (bookRef.id !== currentYearsBookId)
    dispatch(setCurrentBookForYear({ id: bookRef.id, year: bookRef.year }))
}

export const shiftYear = shift => changeSelectedYear(state => {
  const years = selectYears()(state)
  const currentYear = selectCurrentBookRef()(state)?.year
  const index = years.indexOf(currentYear)
  if (index < 0) return null

  const targetIndex = clamp(index + shift, 0, years.length - 1)
  return years[targetIndex]
})

export const jumpToFirstYear = () => changeSelectedYear(state => first(selectYears()(state)))

export const jumpToLastYear = () => changeSelectedYear(state => {
  const availableYears = selectYears()(state)
  const currentYear = new Date().getFullYear()
  if (availableYears.includes(currentYear)) return currentYear
  return last(availableYears)
})

export const shiftSelection = shift => (dispatch, getState) => {
  const state = getState()
  const currentBookRef = selectCurrentBookRef()(state)
  const yearBookIds = selectShuffledBooksOfYear(currentBookRef.year)(state).map(book => book.id)
  const displayedBookIds = pickNearEntries(yearBookIds, currentBookRef.id, { lengthBefore: 1, lengthAfter: 1 })
  const targetId = shift > 0 ? last(displayedBookIds) : first(displayedBookIds)
  if (!targetId) return

  dispatch(showBook(targetId))
}

export const jumpToLatestYear = () => (dispatch, getState) => {
  const availableYears = selectYears()(getState())
  const currentYear = new Date().getFullYear()
  const targetYear = availableYears.includes(currentYear) ? currentYear : last(availableYears)
  dispatch(jumpToYear(targetYear))
}

export const loadCurrentBookDetails = () => async(dispatch, getState) => {
  const currentId = selectCurrentBookId()(getState())
  if (!currentId) return

  const details = await apiClient.getBookFull(currentId)
  dispatch(setCurrentBookDetails(details))
}

export const fetchYears = (query = {}) => async dispatch => {
  const years = await apiClient.getBooksYears(query)
  dispatch(addYears(years))
}

export const reloadBook = id => async dispatch => {
  const book = await apiClient.getBooksIndexEntry(id)
  dispatch(addBook(book))
  dispatch(updateBookInYears(book))
  dispatch(showBook(id))
}

const updateBookInYears = book => (dispatch, getState) => {
  const state = getState()
  const years = selectYears()(state)
  const previousYear = selectCurrentBookRef()(state)?.year

  if (!years.includes(book.year)) dispatch(addYears([book.year]))

  if (previousYear && previousYear !== book.year) {
    const yearBook = selectBooksIndex()(state).find(b => b.year === previousYear)
    if (!yearBook)
      setYears(years.filter(year => year !== previousYear))
  }
}

export const reloadBooks = () => dispatch => {
  dispatch(clearListState())
  dispatch(setupBooksListSelection())
}

export const addTagToBook = (id, tagName) => (dispatch, getState) => {
  const state = getState()
  const book = selectBooksIndexEntry(id)(state)
  const tagNames = selectTagNames(book.tagIds)(state)
  tagNames.push(tagName)
  apiClient.updateBook(id, { tagNames }).then(() =>
    dispatch(reloadBook(id))
  )
}

export const removeTagFromBook = (id, tagName) => (dispatch, getState) => {
  const state = getState()
  const book = selectBooksIndexEntry(id)(state)
  const tagNames = selectTagNames(book.tagIds)(state)
  pull(tagNames, tagName)
  tagNames.push('')
  apiClient.updateBook(id, { tagNames }).then(() =>
    dispatch(reloadBook(id))
  )
}

export const jumpToYear = year => dispatch => {
  dispatch(requestYearRefsLoaded(year)).then(() => {
    dispatch(switchToBookByYear(year))
  })
}

// PRIVATES


const changeSelectedYear = selectTargetYear => (dispatch, getState) => {
  const targetYear = selectTargetYear(getState())
  dispatch(jumpToYear(targetYear))
}

const switchToBookByYear = targetYear => (dispatch, getState) => {
  const state = getState()
  const bookIdPreselected = selectYearCurrentBookId(targetYear)(state)
  if (bookIdPreselected)
    dispatch(showBook(bookIdPreselected))
  else {
    const bookId = first(selectBookIdsByYear(targetYear)(state))
    if (!bookId) return
    dispatch(showBook(bookId))
  }
}

export const requestBookIndexNeighboursLoaded = () => (dispatch, getState) => {
  const state = getState()
  const ids = selectBookIdsToDisplay()(state)
  dispatch(fetchMissingBookIndexEntries(ids))
}

export const clearListState = () => dispatch => {
  dispatch(clearBooksRefs())
  dispatch(clearListInnerState())
  dispatch(clearYearsInnerState())
}

