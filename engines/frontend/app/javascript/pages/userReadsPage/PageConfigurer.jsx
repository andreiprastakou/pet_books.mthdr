import { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import PropTypes from 'prop-types'

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
import apiClient from 'store/userReadsSharings/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const BOOKS_PER_PAGE = 40

const Configurer = ({ code, onStatus }) => {
  const dispatch = useDispatch()
  const { pageState: { page, sortBy }, routesReady } = useContext(UrlStoreContext)
  const listStateReady = page !== undefined && sortBy !== undefined
  const loadedKey = useRef(null)
  const verifiedCode = useRef(null)
  const activeCode = useRef(code)
  activeCode.current = code

  useEffect(() => {
    if (!routesReady || !listStateReady || !code) return

    const resolvedSort = sortBy || 'random'
    const key = `${code}:${page}:${resolvedSort}`
    if (loadedKey.current === key) return
    loadedKey.current = key

    const codeChanged = verifiedCode.current !== code
    if (codeChanged) {
      verifiedCode.current = null
      onStatus('loading')
      dispatch(setPageIsLoading(true))
      dispatch(clearListState())
      dispatch(assignPerPage(BOOKS_PER_PAGE))
    }

    dispatch(assignSortBy(resolvedSort))
    dispatch(assignPage(page))

    const prepare = codeChanged
      ? apiClient.get(code).then(() => {
        if (activeCode.current !== code) return 'stale'
        verifiedCode.current = code
        onStatus('ready')
        dispatch(assignFilter({ readsCode: code }))
        return Promise.all([
          dispatch(prepareNavRefs()),
          dispatch(fetchCoverDesigns()),
        ])
      }).catch(error => {
        if (activeCode.current !== code) return 'stale'
        if (error?.status === 404) {
          onStatus('missing')
          return 'missing'
        }
        throw error
      })
      : Promise.resolve()

    prepare.then(result => {
      if (result === 'missing' || result === 'stale' || activeCode.current !== code) return null
      return dispatch(fetchBooks()).then(() => {
        if (codeChanged) dispatch(setupBooksListSelection())
      })
    }).catch(() => {
      if (activeCode.current === code)
        dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      if (codeChanged && activeCode.current === code) dispatch(setPageIsLoading(false))
    })
  }, [code, listStateReady, onStatus, page, routesReady, sortBy])

  return null
}

Configurer.propTypes = {
  code: PropTypes.string,
  onStatus: PropTypes.func.isRequired,
}

export default Configurer
