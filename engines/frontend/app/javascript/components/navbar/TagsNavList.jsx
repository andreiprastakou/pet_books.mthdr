import React, { useCallback, useContext, useState } from 'react'
import { NavDropdown } from 'react-bootstrap'

import InternalLink from 'components/InternalLink'
import SearchForm from 'components/navbar/SearchForm'
import apiClient from 'store/tags/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const TagsNavList = () => {
  const { routes: { tagPagePath } } = useContext(UrlStoreContext)
  const [searchEntries, setSearchEntries] = useState([])

  const apiSearcher = useCallback(key => apiClient.search(key).then(results => {
    setSearchEntries(results)
  }), [])

  return (
    <div className='tags-nav'>
      <div className='nav-search-form'>
        <SearchForm
          apiSearcher={apiSearcher}
          focusEvent='TAGS_NAV_CLICKED'
        />
      </div>

      <div className='nav-search-list'>
        { searchEntries.map(searchEntry => (
          <NavDropdown.Item
            as={InternalLink}
            href={tagPagePath(searchEntry.tagId)}
            key={searchEntry.tagId}
          >
            { searchEntry.label }
          </NavDropdown.Item>
        )) }
      </div>
    </div>
  )
}

export default TagsNavList
