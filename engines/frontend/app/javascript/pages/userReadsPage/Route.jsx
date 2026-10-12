import React, { useContext, useEffect, useRef, useState } from 'react'
import { useParams } from 'react-router-dom'

import UserReadsPage from 'pages/userReadsPage/Page'
import PageConfigurer from 'pages/userReadsPage/PageConfigurer'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute(
      'userReadsPagePath',
      code => buildPath({ path: `/reads/${code}` })
    )
    return removeRoute
  }, [])
  return null
}

const path = '/reads/:code'

const Renderer = () => {
  const { code } = useParams()
  const [status, setStatus] = useState('loading')
  const codeRef = useRef(code)
  if (codeRef.current !== code) {
    codeRef.current = code
    setStatus('loading')
  }

  return (
    <>
      <BooksListConfigurer />

      <PageConfigurer
        code={code}
        onStatus={setStatus}
      />

      <UserReadsPage status={status} />
    </>
  )
}

export default { path, Renderer, Helper }
