import { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'

import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { setCurrentBookId } from 'store/axis/actions'
import { prepareNavRefs } from 'store/navbar/actions'
import {
  addYears,
  clearState as clearYears,
} from 'store/booksYears/actions'
import {
  assignFilter,
  assignPerPage,
  assignSortBy,
  clearListState,
  assignPage,
  fetchBooks,
  switchToFirstBook,
} from 'store/booksList/actions'
import apiClient from 'store/books/apiClient'
import { setPageIsLoading } from 'store/metadata/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BOOKS_PER_PAGE = 1000

const PageConfigurer = () => {
  const dispatch = useDispatch()
  const { pageState, routesReady } = useContext(UrlStoreContext)
  const { bookId } = pageState
  const bookIdStateReady = Object.hasOwn(pageState, 'bookId')
  const hasConfigured = useRef(false)

  useEffect(() => {
    if (hasConfigured.current || !routesReady || !bookIdStateReady) return
    hasConfigured.current = true

    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(clearYears())
    dispatch(assignPerPage(BOOKS_PER_PAGE))
    dispatch(assignPage(1))
    dispatch(assignSortBy('random'))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchCoverDesigns()),
      apiClient.getBooksYears(),
      bookId ? apiClient.getBookRefEntry(bookId) : Promise.resolve(null),
    ]).then(([, , years, book]) => {
      const year = book?.year || years[years.length - 1]
      dispatch(addYears(years))
      dispatch(assignFilter({ years: [year] }))
      if (book) dispatch(setCurrentBookId(book.id))
      return dispatch(fetchBooks())
    }).then(() => {
      dispatch(switchToFirstBook())
      dispatch(setPageIsLoading(false))
    })
  }, [bookId, bookIdStateReady, routesReady])

  return null
}

export default PageConfigurer
