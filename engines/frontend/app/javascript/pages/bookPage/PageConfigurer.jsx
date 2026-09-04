import { useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import { addBooks } from 'store/books/actions'
import apiClient from 'store/books/apiClient'
import { setCurrentBookId } from 'store/axis/actions'
import { addErrorMessage } from 'store/notifications/actions'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import { prepareNavRefs } from 'store/navbar/actions'

const PageConfigurer = () => {
  const { bookId } = useParams()
  const dispatch = useDispatch()

  useEffect(() => {
    let active = true
    const id = parseInt(bookId, 10)

    dispatch(setPageIsLoading(true))
    dispatch(setCurrentBookId(null))

    Promise.all([
      dispatch(prepareNavRefs()),
      dispatch(fetchCoverDesigns()),
      apiClient.getBooksIndexEntry(id),
    ]).then(([, , book]) => {
      if (!active) return
      dispatch(addBooks([book]))
      dispatch(setCurrentBookId(book.id))
    }).catch(() => {
      if (active) dispatch(addErrorMessage('Unable to load this book. Please try again.'))
    }).finally(() => {
      if (active) dispatch(setPageIsLoading(false))
    })

    return () => {
      active = false
      dispatch(setCurrentBookId(null))
    }
  }, [bookId, dispatch])

  return null
}

export default PageConfigurer
