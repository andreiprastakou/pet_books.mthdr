import React, { useContext, useEffect } from 'react'
import { useParams } from 'react-router-dom'

import BookPage from 'pages/bookPage/Page'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute(
      'bookPagePath',
      id => buildPath({ path: `/books/${id}` })
    )
    return removeRoute
  }, [])

  return null
}

const path = '/books/:bookId'

const Renderer = () => (
  <>
    <BookPageSelection />

    <BookPage />
  </>
)

const BookPageSelection = () => {
  const { bookId } = useParams()
  const { actions: { addUrlAction }, getActions, getRoutes } = useContext(UrlStoreContext)

  useEffect(() => addUrlAction(
    'showBooksIndexEntry',
    id => {
      if (id === parseInt(bookId, 10)) return

      getActions().goto(getRoutes().bookPagePath(id))
    }
  ), [addUrlAction, bookId, getActions, getRoutes])

  return null
}

export default { path, Renderer, Helper }
