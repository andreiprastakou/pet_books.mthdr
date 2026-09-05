import React, { useContext, useEffect } from 'react'
import { useDispatch } from 'react-redux'

import { setCurrentAuthorId } from 'store/axis/actions'
import { assignPage, assignPerPage, assignSortBy } from 'pages/authorsPage/actions'
import AuthorsPage from 'pages/authorsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('authorsPagePath', () => buildPath({ path: '/authors' }))
    return removeRoute
  }, [])
  return null
}

const path = '/authors'

const Renderer = () => (
  <>
    <LocalStoreConfigurer />

    <AuthorsPage />
  </>
)

const LocalStoreConfigurer = () => {
  const dispatch = useDispatch()

  const { actions: { addRoute, addUrlAction, addUrlState, patch },
    helpers: { buildPath, buildRelativePath },
    pageState,
    getRoutes,
  } = useContext(UrlStoreContext)

  useEffect(() => {
    const removePaginationRoute = addRoute(
      'indexPaginationPath',
      (page, perPage) => buildRelativePath({ params: { page, per_page: perPage } })
    )

    const removeAuthorState = addUrlState('authorId', url => parseInt(url.queryParameter('author_id')))

    const removeSortOrderState = addUrlState('sortOrder', url => url.queryParameter('sort_order'))

    const removePageState = addUrlState('page', url => parseInt(url.queryParameter('page')) || null)

    const removePerPageState = addUrlState('perPage', url => parseInt(url.queryParameter('per_page')) || null)

    const removeSortState = addUrlState('sortBy', url => url.queryParameter('sort_by'))

    const removeChangeSortAction = addUrlAction(
      'changeSortOrder',
      order => patch(buildPath({ params: { 'sort_order': order } }))
    )

    const removeShowAuthorAction = addUrlAction(
      'showAuthor',
      id => patch(buildRelativePath({ params: { 'author_id': id } }))
    )

    const removeAuthorWidgetAction = addUrlAction(
      'removeAuthorWidget',
      () => patch(buildPath({ params: { 'author_id': null } }))
    )

    const removePageAction = addUrlAction(
      'switchToIndexPage',
      (page, perPage) => patch(getRoutes().indexPaginationPath(page, perPage))
    )

    const removeSortAction = addUrlAction(
      'switchToIndexSort',
      sortBy => patch(buildRelativePath({ params: { page: 1, sort_by: sortBy } }))
    )

    return () => {
      removePaginationRoute()
      removeAuthorState()
      removeSortOrderState()
      removePageState()
      removePerPageState()
      removeSortState()
      removeChangeSortAction()
      removeShowAuthorAction()
      removeAuthorWidgetAction()
      removePageAction()
      removeSortAction()
    }
  }, [])

  const { authorId, page, perPage, sortBy } = pageState

  useEffect(() => {
    dispatch(assignPage(page))
    dispatch(assignPerPage(perPage))
    dispatch(assignSortBy(sortBy))
    dispatch(setCurrentAuthorId(authorId))
  }, [authorId, page, perPage, sortBy])

  return null
}

export default { path, Renderer, Helper }
