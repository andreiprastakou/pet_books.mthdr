import React, { useCallback, useContext, useState } from 'react'
import { NavDropdown } from 'react-bootstrap'

import apiClient from 'store/tags/apiClient'
import SearchForm from 'widgets/navbar/components/SearchForm'
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
            href={tagPagePath(searchEntry.tagId)}
            key={searchEntry.tagId}
          >
            { searchEntry.highlight }
          </NavDropdown.Item>
        )) }
      </div>
    </div>
  )
}

export default TagsNavList
