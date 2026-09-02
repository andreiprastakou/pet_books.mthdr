import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Pagination as BootstrapPagination } from 'react-bootstrap'
import PropTypes from 'prop-types'

import UrlStoreContext from 'store/urlStore/Context'

const Pagination = ({ selectTotal, selectPage, selectPerPage }) => {
  const totalCount = useSelector(selectTotal())
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
      <BootstrapPagination.Item
        className='internal-link'
        href={indexPaginationPath(pageNumber, perPage)}
        onClick={handlePageClick(pageNumber)}
        title={pageNumber}
      >
        { pageNumber }
      </BootstrapPagination.Item>
    )
  }

  return (
    <BootstrapPagination className='pagination'>
      { page > 2 && renderPageLink(1) }

      { renderPageLink(page - 1) }

      <BootstrapPagination.Item
        active
        disabled
      >
        { page }
      </BootstrapPagination.Item>

      { renderPageLink(page + 1) }

      { lastPage - page > 1 && renderPageLink(lastPage) }
    </BootstrapPagination>
  )
}

Pagination.propTypes = {
  selectPage: PropTypes.func.isRequired,
  selectPerPage: PropTypes.func.isRequired,
  selectTotal: PropTypes.func.isRequired,
}

export default Pagination
