import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { addErrorMessage } from 'store/notifications/actions'
import { selectCurrentTagId } from 'store/axis/selectors'
import { setPageIsLoading } from 'store/metadata/actions'
import {
  assignFilter,
  assignPerPage,
  assignSortBy,
  clearListState,
  fetchBooks,
  setupBooksListSelection,
} from 'store/booksList/actions'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'store/navbar/actions'
import { fetchTagsIndexEntry } from 'store/tags/actions'

const Configurer = () => {
  const dispatch = useDispatch()
  const tagId = useSelector(selectCurrentTagId())

  useEffect(() => {
    if (!tagId)  return
    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(assignSortBy('popularity'))
    dispatch(assignPerPage(40))
    dispatch(assignFilter({ tagIds: [tagId] }))
    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchTagsIndexEntry(tagId)),
      dispatch(fetchCoverDesigns()),
    ]).then(() => dispatch(fetchBooks())).then(() => {
      dispatch(setupBooksListSelection())
    }).catch(() => {
      dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [tagId])

  return null
}

export default Configurer
