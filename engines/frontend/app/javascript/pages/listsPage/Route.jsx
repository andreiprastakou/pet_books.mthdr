import React, { useContext, useEffect } from 'react'

import ListsPage from 'pages/listsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('listPagePath', id => buildPath({ path: `/lists/${id}` }))
    return removeRoute
  }, [])

  return null
}

const path = '/lists/:id'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <ListsPage />
  </>
)

export default { path, Renderer, Helper }
