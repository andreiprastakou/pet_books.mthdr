import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { selectCurrentAuthorId } from 'store/axis/selectors'
import { fetchAuthorFull } from 'store/authors/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import {
  assignFilter,
  assignPerPage,
  assignSortBy,
  clearListState,
  fetchBooks,
} from 'widgets/booksListLinear/actions'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'

const Configurer = () => {
  const dispatch = useDispatch()
  const authorId = useSelector(selectCurrentAuthorId())

  useEffect(() => {
    if (!authorId)  return
    dispatch(setPageIsLoading(true))
    dispatch(clearListState())
    dispatch(assignSortBy('year'))
    dispatch(assignPerPage(60))
    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchAuthorFull(authorId)),
      dispatch(fetchCoverDesigns()),
    ]).then(() => {
      dispatch(assignFilter({ authorId }))
      dispatch(fetchBooks()).then(() => {
        dispatch(setPageIsLoading(false))
      })
    })
  }, [authorId])

  return null
}

export default Configurer
