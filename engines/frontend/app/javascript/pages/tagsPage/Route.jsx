import React, { useContext, useEffect } from 'react'

import UrlStoreContext from 'store/urlStore/Context'
import TagsPage from 'pages/tagsPage/Page'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    addRoute('tagsPagePath', () => buildPath({ path: '/tags/' }))
  }, [])

  return null
}

const path = '/tags'

const Renderer = () => (
  <TagsPage />
)

export default { path, Renderer, Helper }
