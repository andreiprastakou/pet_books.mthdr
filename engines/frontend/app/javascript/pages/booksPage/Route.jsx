import React, { useContext, useEffect, useLayoutEffect } from 'react'

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

const Renderer = () => {
  useLayoutEffect(() => {
    document.body.classList.add('is-compact-layout')

    return () => document.body.classList.remove('is-compact-layout')
  }, [])

  return (
    <>
      <BooksListConfigurer />

      <BooksPage />
    </>
  )
}

export default { path, Renderer, Helper }
