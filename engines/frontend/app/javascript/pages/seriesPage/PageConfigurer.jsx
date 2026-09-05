import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { addErrorMessage } from 'store/notifications/actions'
import { selectCurrentSeriesId } from 'store/axis/selectors'
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
import { fetchSeriesIndexEntry } from 'store/series/actions'

const Configurer = () => {
  const dispatch = useDispatch()
  const seriesId = useSelector(selectCurrentSeriesId())

  useEffect(() => {
    if (!seriesId) return
    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(assignSortBy('year'))
    dispatch(assignPerPage(1000))
    dispatch(assignPage(1))
    dispatch(assignFilter({ seriesId }))
    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchSeriesIndexEntry(seriesId)),
      dispatch(fetchCoverDesigns()),
    ]).then(() => dispatch(fetchBooks())).then(() => {
      dispatch(setupBooksListSelection())
    }).catch(() => {
      dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [seriesId])

  return null
}

export default Configurer
