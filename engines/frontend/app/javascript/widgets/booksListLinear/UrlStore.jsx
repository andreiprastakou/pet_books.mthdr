import { useContext, useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { setCurrentBookId } from 'store/axis/actions'
import { selectRequestedBookId } from 'store/books/selectors'
import { setRequestedBookId } from 'store/books/actions'
import { selectPageIsLoading } from 'store/metadata/selectors'
import { assignPage, assignPerPage, assignSortBy } from 'widgets/booksListLinear/actions'
import UrlStoreContext from 'store/urlStore/Context'

const LocalStoreConfigurer = () => {
  const dispatch = useDispatch()
  const { pageState,
    actions: { addRoute, addUrlAction, addUrlState, patch },
    helpers: { buildRelativePath },
    routes: { indexPaginationPath },
    getActions,
  } = useContext(UrlStoreContext)
  const requestedBookId = useSelector(selectRequestedBookId())
  const pageLoading = useSelector(selectPageIsLoading())
  const [storeReady, setStoreReady] = useState(false)

  /* eslint-disable camelcase */
  useEffect(() => {
    addRoute('indexPaginationPath', (page, perPage) => buildRelativePath({ params: { page, per_page: perPage } }))

    addUrlAction('showBooksIndexEntry', id => getActions().patch(buildRelativePath({ params: { 'book_id': id } })))

    addUrlAction('switchToIndexPage', (page, perPage) => patch(indexPaginationPath(page, perPage)))

    addUrlAction('switchToIndexSort', sortBy => patch(buildRelativePath({ params: { page: 1, sort_by: sortBy } })))

    addUrlState('bookId', url => parseInt(url.queryParameter('book_id')))

    addUrlState('page', url => parseInt(url.queryParameter('page')) || null)

    addUrlState('perPage', url => parseInt(url.queryParameter('per_page')) || null)

    addUrlState('sortBy', url => url.queryParameter('sort_by'))
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

export default LocalStoreConfigurer
