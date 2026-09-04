import React, { useContext, useEffect } from 'react'

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
  <BookPage />
)

export default { path, Renderer, Helper }
