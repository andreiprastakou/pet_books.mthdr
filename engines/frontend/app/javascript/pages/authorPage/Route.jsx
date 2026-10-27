import React, { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import { setCurrentAuthorId } from 'store/axis/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import AuthorPage from 'pages/authorPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('authorPagePath', (id, { bookId } = {}) =>
      buildPath({ path: `/authors/${id}`, params: { 'book_id': bookId } }))
    return removeRoute
  }, [])
  return null
}

const path = '/authors/:authorId'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <LocalStoreConfigurer />

    <AuthorPage />
  </>
)

const LocalStoreConfigurer = () => {
  const params = useParams()
  const paramsRef = useRef()
  paramsRef.current = params
  const dispatch = useDispatch()

  const { actions: { addUrlAction, addUrlState, patch },
    helpers: { buildRelativePath },
    pageState: { authorId }
  } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeAuthorState = addUrlState('authorId', () => parseInt(paramsRef.current.authorId))
    const removeSortState = addUrlState('sortBy', url => url.queryParameter('sort_by'))
    const removeSortAction = addUrlAction('switchToIndexSort', sortBy =>
      patch(buildRelativePath({ params: { page: 1, sort_by: sortBy } })))

    dispatch(setPageIsLoading(true))
    dispatch(setCurrentAuthorId(authorId))

    return () => {
      removeAuthorState()
      removeSortState()
      removeSortAction()
    }
  }, [authorId])

  return null
}

export default { path, Renderer, Helper }
