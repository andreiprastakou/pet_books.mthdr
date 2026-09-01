import React, { useContext, useEffect } from 'react'

import PublicListsPage from 'pages/publicListsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('listPagePath', id => buildPath({ path: `/public-lists/${id}` }))
    return removeRoute
  }, [])

  return null
}

const path = '/public-lists/:id'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <PublicListsPage />
  </>
)

export default { path, Renderer, Helper }
