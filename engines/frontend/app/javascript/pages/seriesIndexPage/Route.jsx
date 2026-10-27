import React, { useContext, useEffect, useLayoutEffect } from 'react'

import UrlStoreContext from 'store/urlStore/Context'
import SeriesIndexPage from 'pages/seriesIndexPage/Page'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('seriesIndexPagePath', () => buildPath({ path: '/series/' }))
    return removeRoute
  }, [])

  return null
}

const path = '/series'

const Renderer = () => {
  useLayoutEffect(() => {
    document.body.classList.add('is-compact-layout')

    return () => document.body.classList.remove('is-compact-layout')
  }, [])

  return <SeriesIndexPage />
}

export default { path, Renderer, Helper }
