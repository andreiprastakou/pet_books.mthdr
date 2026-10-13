import { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'

import { addErrorMessage } from 'store/notifications/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import {
  assignFilter,
  assignPage,
  assignPerPage,
  assignSortBy,
  clearListState,
  fetchBooks,
  setupBooksListSelection,
} from 'store/booksList/actions'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'store/navbar/actions'
import UrlStoreContext from 'store/urlStore/Context'
import { notNullish } from 'utils/nullish'

const BOOKS_PER_PAGE = 40

const Configurer = () => {
  const dispatch = useDispatch()
  const { pageState: { page, sortBy }, routesReady } = useContext(UrlStoreContext)
  const listStateReady = notNullish(page) && notNullish(sortBy)
  const loadedKey = useRef(null)

  useEffect(() => {
    if (!routesReady || !listStateReady) return

    const resolvedSort = sortBy || 'random'
    const key = `${page}:${resolvedSort}`
    if (loadedKey.current === key) return

    const firstLoad = loadedKey.current === null
    loadedKey.current = key

    if (firstLoad) {
      dispatch(setPageIsLoading(true))
      dispatch(clearListState())
      dispatch(assignPerPage(BOOKS_PER_PAGE))
      dispatch(assignFilter({ read: true }))
    }

    dispatch(assignSortBy(resolvedSort))
    dispatch(assignPage(page))

    const dependencies = firstLoad
      ? Promise.all([
        dispatch(prepareNavRefs()),
        dispatch(fetchCoverDesigns()),
      ])
      : Promise.resolve()

    dependencies.then(() => dispatch(fetchBooks())).then(() => {
      if (firstLoad) dispatch(setupBooksListSelection())
    }).catch(() => {
      dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      if (firstLoad) dispatch(setPageIsLoading(false))
    })
  }, [listStateReady, page, routesReady, sortBy])

  return null
}

export default Configurer
