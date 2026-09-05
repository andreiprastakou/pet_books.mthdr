import React, { useContext, useEffect } from 'react'

import PublicListsPage from 'pages/publicListsPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('listPagePath', (id, { bookId, listId } = {}) =>
      buildPath({ path: `/public-lists/${id}`, params: { 'book_id': bookId, 'list_id': listId } }))
    return removeRoute
  }, [])

  return null
}

const path = '/public-lists/:id'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <LocalStoreConfigurer />

    <PublicListsPage />
  </>
)

const LocalStoreConfigurer = () => {
  const { actions: { addUrlAction, addUrlState, patch },
    helpers: { buildRelativePath },
  } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeListIdState = addUrlState('listId', url => {
      const raw = url.queryParameter('list_id')
      if (raw === null) return null
      const value = parseInt(raw)
      return Number.isNaN(value) ? null : value
    })
    /* eslint-disable camelcase */
    const removeSelectAction = addUrlAction('selectPublicList', listId =>
      patch(buildRelativePath({ params: { list_id: listId } })))
    /* eslint-enable camelcase */

    return () => {
      removeListIdState()
      removeSelectAction()
    }
  }, [])

  return null
}

export default { path, Renderer, Helper }
