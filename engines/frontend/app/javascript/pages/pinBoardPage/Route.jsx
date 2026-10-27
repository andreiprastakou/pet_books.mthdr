import React, { useContext, useEffect, useLayoutEffect } from 'react'

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

const Renderer = () => {
  useLayoutEffect(() => {
    document.body.classList.add('is-compact-layout')

    return () => document.body.classList.remove('is-compact-layout')
  }, [])

  return <PinBoardPage />
}

export default { path, Renderer, Helper }
