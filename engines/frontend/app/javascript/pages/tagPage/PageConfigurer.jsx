import { useEffect, useRef } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { addErrorMessage } from 'store/notifications/actions'
import { selectCurrentTagId } from 'store/axis/selectors'
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
import { selectPage } from 'store/booksList/selectors'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'store/navbar/actions'
import { fetchTagsIndexEntry } from 'store/tags/actions'

const Configurer = () => {
  const dispatch = useDispatch()
  const tagId = useSelector(selectCurrentTagId())
  const page = useSelector(selectPage())
  const pageRef = useRef(page)
  pageRef.current = page
  const loadedPage = useRef(null)

  useEffect(() => {
    if (!tagId)  return
    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(assignSortBy('popularity'))
    dispatch(assignPerPage(40))
    // clearListState resets the page, so the one taken from the url has to be restored
    dispatch(assignPage(pageRef.current))
    dispatch(assignFilter({ tagIds: [tagId] }))
    loadedPage.current = pageRef.current
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

  useEffect(() => {
    if (!tagId || loadedPage.current === null || loadedPage.current === page) return
    loadedPage.current = page

    // the books list panel selects an entry of its own once the ids change
    dispatch(fetchBooks()).catch(() => {
      dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    })
  }, [page, tagId])

  return null
}

export default Configurer
