import React, { useCallback, useContext, useState } from 'react'
import { NavDropdown } from 'react-bootstrap'

import InternalLink from 'components/InternalLink'
import SearchForm from 'components/navbar/SearchForm'
import apiClient from 'store/series/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const SeriesNavList = () => {
  const { routes: { seriesPagePath } } = useContext(UrlStoreContext)
  const [searchEntries, setSearchEntries] = useState([])

  const apiSearcher = useCallback(key => apiClient.search(key).then(results => {
    setSearchEntries(results)
  }), [])

  return (
    <div className='series-nav'>
      <div className='nav-search-form'>
        <SearchForm
          apiSearcher={apiSearcher}
          focusEvent='SERIES_NAV_CLICKED'
        />
      </div>

      <div className='nav-search-list'>
        { searchEntries.map(searchEntry => (
          <NavDropdown.Item
            as={InternalLink}
            href={seriesPagePath(searchEntry.seriesId)}
            key={searchEntry.seriesId}
          >
            { searchEntry.label }
          </NavDropdown.Item>
        )) }
      </div>
    </div>
  )
}

export default SeriesNavList
