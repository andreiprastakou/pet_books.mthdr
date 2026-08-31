import { useContext, useEffect } from 'react'
import { useDispatch } from 'react-redux'

import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'
import {
  addYears,
  clearListInnerState as clearYears,
} from 'widgets/booksListYearly/actions'
import {
  assignFilter,
  assignPerPage,
  assignSortBy,
  clearListState,
  assignPage,
  fetchBooks,
  switchToFirstBook,
} from 'widgets/booksListLinear/actions'
import apiClient from 'store/books/apiClient'
import { setPageIsLoading } from 'store/metadata/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BOOKS_PER_PAGE = 1000

const PageConfigurer = () => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)

  useEffect(() => {
    if (!routesReady) return

    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(clearYears())
    dispatch(assignPerPage(BOOKS_PER_PAGE))
    dispatch(assignPage(1))
    dispatch(assignSortBy('name'))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchCoverDesigns()),
      apiClient.getBooksYears(),
    ]).then(([, , years]) => {
      const year = years[years.length - 1]
      dispatch(addYears(years))
      dispatch(assignFilter({ years: [year] }))
      return dispatch(fetchBooks())
    }).then(() => {
      dispatch(switchToFirstBook())
      dispatch(setPageIsLoading(false))
    })
  }, [routesReady])

  return null
}

export default PageConfigurer
