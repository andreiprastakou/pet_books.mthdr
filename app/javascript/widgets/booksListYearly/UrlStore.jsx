import { useContext, useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { setCurrentBookId } from 'store/axis/actions'
import { selectRequestedBookId } from 'store/books/selectors'
import { setRequestedBookId } from 'store/books/actions'
import { selectPageIsLoading } from 'store/metadata/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const LocalStoreConfigurer = () => {
  const dispatch = useDispatch()
  const { pageState: { bookId },
    actions: { addUrlAction, addUrlState },
    helpers: { buildRelativePath },
    getActions,
    routesReady,
  } = useContext(UrlStoreContext)
  const requestedBookId = useSelector(selectRequestedBookId())
  const pageLoading = useSelector(selectPageIsLoading())
  const [storeReady, setStoreReady] = useState(false)

  useEffect(() => {
    addUrlAction('showBooksIndexEntry', id =>
      getActions().patch(buildRelativePath({ params: { 'book_id': id } }))
    )

    addUrlState('bookId', url => parseInt(url.queryParameter('book_id')))
  }, [])

  useEffect(() => {
    if (!storeReady || pageLoading || !requestedBookId) return

    dispatch(setRequestedBookId(null))
    if (requestedBookId !== bookId)
      getActions().showBooksIndexEntry(requestedBookId)
  }, [pageLoading, storeReady, requestedBookId])

  useEffect(() => {
    if (routesReady)
      dispatch(setCurrentBookId(bookId))


    setStoreReady(true)
  }, [bookId])

  return null
}

export default LocalStoreConfigurer
