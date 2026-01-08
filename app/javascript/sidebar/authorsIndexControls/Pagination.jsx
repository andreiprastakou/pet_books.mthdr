import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Pagination } from 'react-bootstrap'

import {
  selectAuthorsTotal,
  selectPage,
  selectPerPage,
} from 'pages/authorsPage/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorsIndexPagination = () => {
  const totalCount = useSelector(selectAuthorsTotal())
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())

  const lastPage = Math.ceil(totalCount / perPage)
  const { actions: { switchToIndexPage }, routes: { indexPaginationPath }, routesReady } = useContext(UrlStoreContext)

  const handlePageClick = useCallback(pageNumber => e => {
    e.preventDefault()
    switchToIndexPage(pageNumber, perPage)
  }, [switchToIndexPage, perPage])

  if (perPage >= totalCount) return null
  if (!routesReady) return null

  const renderPageLink = pageNumber => {
    if (pageNumber < 1 || pageNumber > lastPage) return null
    return (
      <Pagination.Item
        href={indexPaginationPath(pageNumber, perPage)}
        onClick={handlePageClick(pageNumber)}
        title={pageNumber}
      >
        { pageNumber }
      </Pagination.Item>
    )
  }
  return (
    <Pagination className='pagination'>
      { page > 2 && renderPageLink(1) }

      { renderPageLink(page - 1) }

      <Pagination.Item
        active
        disabled
      >
        { page }
      </Pagination.Item>

      { renderPageLink(page + 1) }

      { lastPage - page > 1 && renderPageLink(lastPage) }
    </Pagination>
  )
}

export default AuthorsIndexPagination
