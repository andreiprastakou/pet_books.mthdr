import React, { useContext, useEffect } from 'react'

import BooksPage from 'pages/booksPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute(
      'booksPagePath',
      ({ bookId } = {}) => buildPath({ path: '/books', params: { 'book_id': bookId } })
    )
    return removeRoute
  }, [])
  return null
}

const path = '/books'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <BooksPage />
  </>
)

export default { path, Renderer, Helper }
