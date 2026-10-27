import React, { useContext, useEffect, useLayoutEffect } from 'react'

import UrlStoreContext from 'store/urlStore/Context'
import TagsPage from 'pages/tagsPage/Page'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('tagsPagePath', () => buildPath({ path: '/tags/' }))
    return removeRoute
  }, [])

  return null
}

const path = '/tags'

const Renderer = () => {
  useLayoutEffect(() => {
    document.body.classList.add('is-compact-layout')

    return () => document.body.classList.remove('is-compact-layout')
  }, [])

  return <TagsPage />
}

export default { path, Renderer, Helper }
