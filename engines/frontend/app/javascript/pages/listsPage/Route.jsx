import React, { useContext, useEffect } from 'react'

import ListsPage from 'pages/listsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    addRoute('listPagePath', id => buildPath({ path: `/lists/${id}` }))
  }, [])

  return null
}

const path = '/lists/:id'

const Renderer = () => (
  <>
    <LocalUrlStoreConfigurer />

    <ListsPage />
  </>
)

export default { path, Renderer, Helper }
