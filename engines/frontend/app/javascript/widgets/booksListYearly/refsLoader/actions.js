import { slice } from 'widgets/booksListYearly/refsLoader/slice'
import apiClient from 'store/books/apiClient'
import { selectCurrentFilters } from 'widgets/booksListYearly/selectors'
import {
  pickYearsToLoad,
  selectYearsInLoading,
  selectYearsToLoad,
} from 'widgets/booksListYearly/refsLoader/selectors'
import {
  addBooksRefs,
} from 'store/books/actions'
const {
  addYearsToLoad,
  clearState,
  markBooksYearsAsLoaded,
  markYearsAsLoaded,
  markYearsAsLoading,
} = slice.actions

export { clearState }

export const requestYearRefsLoaded = year => async(dispatch, getState) => {
  const state = getState()
  const yearsToLoad = pickYearsToLoad(year)(state)

  if (yearsToLoad.includes(year))
    await dispatch(fetchBooksForYears(yearsToLoad))
  else
    dispatch(fetchBooksForYears(yearsToLoad))
}

// PRIVATE

const fetchBooksForYears = years => async(dispatch, getState) => {
  if (!years.length) return

  dispatch(addYearsToLoad(years))
  const refEntries = await loadRequestedBookRefs(dispatch, getState)
  if (refEntries.length > 0) dispatch(addBooksRefs(refEntries))
  dispatch(markBooksYearsAsLoaded(refEntries))
}

const loadRequestedBookRefs = (dispatch, getState) => {
  const yearsToLoad = selectYearsToLoad()(getState())
  if (yearsToLoad.length < 1) return []

  return new Promise(resolve => {
    lazyLoadBookRefIteration(dispatch, getState, resolve)
  })
}

const lazyLoadBookRefIteration = (dispatch, getState, resolve, index = 0) => {
  if (index > 100) {
    resolve([])
    return null
  }
  return setTimeout(() => {
    const state = getState()
    const yearsToLoad = selectYearsToLoad()(state)
    const yearsInLoading = selectYearsInLoading()(state)
    const currentFilters = selectCurrentFilters()(state)
    if (yearsToLoad.length < 1)
      resolve([])
    else if (yearsInLoading.length > 0)
      lazyLoadBookRefIteration(dispatch, getState, resolve, index + 1)
    else {
      dispatch(markYearsAsLoading())
      const query = { years: yearsToLoad, ...currentFilters }
      apiClient.getBooksRefs(query).then(({ books }) => {
        dispatch(markYearsAsLoaded(yearsToLoad))
        resolve(books)
      })
    }
  }, 100 + Math.floor(Math.random() * 100))
}
