import React, { useContext, useEffect, useLayoutEffect } from 'react'

import ReadsPage from 'pages/readsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('readsPagePath', () => buildPath({ path: '/reads' }))
    return removeRoute
  }, [])
  return null
}

const path = '/reads'

const Renderer = () => {
  useLayoutEffect(() => {
    document.body.classList.add('is-compact-layout')

    return () => document.body.classList.remove('is-compact-layout')
  }, [])

  return (
    <>
      <BooksListConfigurer />

      <ReadsPage />
    </>
  )
}

export default { path, Renderer, Helper }
