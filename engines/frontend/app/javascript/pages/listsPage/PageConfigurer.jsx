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
} from 'store/booksList/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BOOKS_PER_PAGE = 1000

const ListsPageConfigurer = ({ bookIds }) => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)

  useEffect(() => {
    if (!routesReady) return

    dispatch(clearListState())
    dispatch(assignFilter({ ids: bookIds }))
    dispatch(assignPage(1))
    dispatch(assignPerPage(BOOKS_PER_PAGE))
    dispatch(assignSortBy('random'))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchCoverDesigns()),
    ]).then(() => dispatch(fetchBooks()))
  }, [bookIds, routesReady])

  return null
}

ListsPageConfigurer.propTypes = {
  bookIds: PropTypes.arrayOf(PropTypes.number).isRequired,
}

export default ListsPageConfigurer
