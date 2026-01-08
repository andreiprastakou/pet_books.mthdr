import { useContext, useEffect } from 'react'
import PropTypes from 'prop-types'
import { useDispatch, useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCurrentBookRef } from 'store/books/selectors'
import { setSeed } from 'store/axis/actions'
import { selectPageIsLoading } from 'store/metadata/selectors'
import { setPageIsLoading } from 'store/metadata/actions'
import {
  clearListState,
  fetchYears,
  requestBookIndexNeighboursLoaded,
  setBookAsCurrentInYear,
  setFilters,
  setupBooksListSelection,
} from 'widgets/booksListYearly/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'
import UrlStoreContext from 'store/urlStore/Context'

const Configurer = ({ listFilter }) => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)
  const currentBookId = useSelector(selectCurrentBookId())
  const currentBookRef = useSelector(selectCurrentBookRef())
  const pageIsLoading = useSelector(selectPageIsLoading())

  useEffect(() => {
    if (!routesReady) return
    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(setSeed())
    dispatch(setFilters(listFilter))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchYears(listFilter)),
    ]).then(() =>
      dispatch(setupBooksListSelection())
    ).then(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [routesReady])

  useEffect(() => {
    if (!routesReady || !currentBookRef || pageIsLoading) return
    dispatch(requestBookIndexNeighboursLoaded())
    dispatch(setBookAsCurrentInYear(currentBookRef))
  }, [routesReady, currentBookRef, pageIsLoading])

  useEffect(() => {
    if (!routesReady) return
    if (!currentBookId) {
      dispatch(setSeed())
      dispatch(setupBooksListSelection())
    }
  }, [routesReady, currentBookId])

  return null
}

Configurer.propTypes = {
  listFilter: PropTypes.object,
}

Configurer.defaultProps = {
  listFilter: {},
}

export default Configurer
