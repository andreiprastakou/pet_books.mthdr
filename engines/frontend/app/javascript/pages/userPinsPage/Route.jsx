import React, { useContext, useEffect, useRef, useState } from 'react'
import { useParams } from 'react-router-dom'

import UserPinsPage from 'pages/userPinsPage/Page'
import PageConfigurer from 'pages/userPinsPage/PageConfigurer'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute(
      'userPinsPagePath',
      code => buildPath({ path: `/pins/${code}` })
    )
    return removeRoute
  }, [])
  return null
}

const path = '/pins/:code'

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
      <PageConfigurer
        code={code}
        onStatus={setStatus}
      />

      <UserPinsPage status={status} />
    </>
  )
}

export default { path, Renderer, Helper }
