import React, { useContext, useEffect } from 'react'

import PinBoardPage from 'pages/pinBoardPage/Page'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('pinBoardPagePath', () => buildPath({ path: '/pins' }))
    return removeRoute
  }, [])

  return null
}

const path = '/pins'

const Renderer = () => (
  <PinBoardPage />
)

export default { path, Renderer, Helper }
