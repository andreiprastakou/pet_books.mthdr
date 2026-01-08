import React, { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import { setCurrentAuthorId } from 'store/axis/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import AuthorPage from 'pages/authorPage/Page'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    addRoute('authorPagePath', (id, { bookId } = {}) =>
      buildPath({ path: `/authors/${id}`, params: { 'book_id': bookId } }))
  }, [])
  return null
}

const path = '/authors/:authorId'

const Renderer = () => (
  <>
    <LocalStoreConfigurer />

    <AuthorPage />
  </>
)

const LocalStoreConfigurer = () => {
  const params = useParams()
  const paramsRef = useRef()
  paramsRef.current = params
  const dispatch = useDispatch()

  const { actions: { addUrlState },
    pageState: { authorId }
  } = useContext(UrlStoreContext)

  useEffect(() => {
    addUrlState('authorId', () => parseInt(paramsRef.current.authorId))

    dispatch(setPageIsLoading(true))
    dispatch(setCurrentAuthorId(authorId))
  }, [authorId])

  return null
}

export default { path, Renderer, Helper }
