import { useContext, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import PropTypes from 'prop-types'

import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'store/navbar/actions'
import {
  assignFilter,
  assignPage,
  assignPerPage,
  assignSortBy,
  clearListState,
  fetchBooks,
  setupBooksListSelection,
} from 'store/booksList/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BOOKS_PER_PAGE = 1000

const PublicListsPageConfigurer = ({ bookIds }) => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)
  const bookIdsKey = bookIds.join(',')

  useEffect(() => {
    if (!routesReady) return

    dispatch(clearListState())
    const ids = bookIdsKey ? bookIdsKey.split(',').map(Number) : []

    dispatch(assignFilter({ ids }))
    dispatch(assignPage(1))
    dispatch(assignPerPage(BOOKS_PER_PAGE))
    dispatch(assignSortBy('random'))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchCoverDesigns()),
    ]).then(() => {
      if (ids.length === 0) return
      return dispatch(fetchBooks()).then(() => dispatch(setupBooksListSelection()))
    })
  }, [bookIdsKey, routesReady])

  return null
}

PublicListsPageConfigurer.propTypes = {
  bookIds: PropTypes.arrayOf(PropTypes.number).isRequired,
}

export default PublicListsPageConfigurer
