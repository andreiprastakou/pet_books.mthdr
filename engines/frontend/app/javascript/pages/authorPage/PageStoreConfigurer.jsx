import { useContext, useEffect, useRef } from 'react'
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
  switchToFirstBook,
} from 'store/booksList/actions'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'
import UrlStoreContext from 'store/urlStore/Context'

const Configurer = () => {
  const dispatch = useDispatch()
  const authorId = useSelector(selectCurrentAuthorId())
  const { pageState: { sortBy } } = useContext(UrlStoreContext)
  const previousAuthorId = useRef()

  useEffect(() => {
    if (!authorId)  return
    const authorChanged = previousAuthorId.current !== authorId
    previousAuthorId.current = authorId

    if (authorChanged) {
      dispatch(setPageIsLoading(true))
      dispatch(clearListState())
    }

    dispatch(assignSortBy(sortBy || 'year'))
    dispatch(assignPerPage(1000))

    const authorDependencies = authorChanged
      ? Promise.all([
        dispatch(prepareNavRefs()),
        dispatch(fetchAuthorFull(authorId)),
        dispatch(fetchCoverDesigns()),
      ]).then(() => dispatch(assignFilter({ authorId })))
      : Promise.resolve()

    authorDependencies.then(() =>
      dispatch(fetchBooks()).then(() => {
        dispatch(switchToFirstBook())
        if (authorChanged) dispatch(setPageIsLoading(false))
      })
    )
  }, [authorId, sortBy])

  return null
}

export default Configurer
