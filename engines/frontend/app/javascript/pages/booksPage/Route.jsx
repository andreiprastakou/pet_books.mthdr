import React, { useContext, useEffect } from 'react'

import BooksPage from 'pages/booksPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import ListUrlStoreConfigurer from 'widgets/booksListYearly/UrlStore'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    addRoute('booksPagePath', ({ bookId } = {}) => buildPath({ path: '/books', params: { 'book_id': bookId } }))
  }, [])
  return null
}

const path = '/books'

const Renderer = () => (
  <>
    <ListUrlStoreConfigurer />

    <BooksPage />
  </>
)

export default { path, Renderer, Helper }
