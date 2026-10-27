import React, { useContext, useEffect } from 'react'

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

const Renderer = () => (
  <SeriesIndexPage />
)

export default { path, Renderer, Helper }
