import { useContext, useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { setCurrentBookId } from 'store/axis/actions'
import { selectRequestedBookId } from 'store/books/selectors'
import { setRequestedBookId } from 'store/books/actions'
import { selectPageIsLoading } from 'store/metadata/selectors'
import { assignPage, assignPerPage, assignSortBy } from 'store/booksList/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BooksListConfigurer = () => {
  const dispatch = useDispatch()
  const { pageState,
    actions: {
      addRoute,
      addUrlAction,
      addUrlState,
      patch,
    },
    helpers: { buildRelativePath },
    getActions,
    getRoutes,
  } = useContext(UrlStoreContext)
  const requestedBookId = useSelector(selectRequestedBookId())
  const pageLoading = useSelector(selectPageIsLoading())
  const [storeReady, setStoreReady] = useState(false)

  /* eslint-disable camelcase */
  useEffect(() => {
    const removeRoute = addRoute(
      'indexPaginationPath',
      (page, perPage) => buildRelativePath({ params: { page, per_page: perPage } })
    )
    const removeShowEntryAction = addUrlAction(
      'showBooksIndexEntry',
      id => getActions().patch(buildRelativePath({ params: { 'book_id': id } }))
    )
    const removePageAction = addUrlAction(
      'switchToIndexPage',
      (page, perPage) => patch(getRoutes().indexPaginationPath(page, perPage))
    )
    const removeSortAction = addUrlAction(
      'switchToIndexSort',
      sortBy => patch(buildRelativePath({ params: { page: 1, sort_by: sortBy } }))
    )
    const removeBookIdState = addUrlState(
      'bookId',
      url => parseInt(url.queryParameter('book_id'))
    )
    const removePageState = addUrlState(
      'page',
      url => parseInt(url.queryParameter('page')) || null
    )
    const removePerPageState = addUrlState(
      'perPage',
      url => parseInt(url.queryParameter('per_page')) || null
    )
    const removeSortState = addUrlState(
      'sortBy',
      url => url.queryParameter('sort_by')
    )

    return () => {
      removeRoute()
      removeShowEntryAction()
      removePageAction()
      removeSortAction()
      removeBookIdState()
      removePageState()
      removePerPageState()
      removeSortState()
    }
  }, [])
  /* eslint-enable camelcase */

  const { bookId, page, perPage, sortBy } = pageState

  useEffect(() => {
    if (!storeReady || pageLoading || !requestedBookId) return

    dispatch(setRequestedBookId(null))
    if (requestedBookId !== bookId)
      getActions().showBooksIndexEntry(requestedBookId)
  }, [storeReady, pageLoading, requestedBookId])

  useEffect(() => {
    dispatch(assignPage(page))
    dispatch(assignPerPage(perPage))
    dispatch(assignSortBy(sortBy))
    dispatch(setCurrentBookId(bookId))

    setStoreReady(true)
  }, [bookId, page, perPage, sortBy])

  return null
}

export default BooksListConfigurer
