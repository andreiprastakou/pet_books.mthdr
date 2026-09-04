import React, { useCallback, useContext, useState } from 'react'
import { NavDropdown } from 'react-bootstrap'

import InternalLink from 'components/InternalLink'
import SearchForm from 'components/navbar/SearchForm'
import apiClient from 'store/authors/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorsNavList = () => {
  const { routes: { authorPagePath } } = useContext(UrlStoreContext)
  const [authorsSearchEntries, setAuthorsSearchEntries] = useState([])

  const handleApiSearcher = useCallback(key => apiClient.search(key).then(searchEntries => {
    setAuthorsSearchEntries(searchEntries)
  }), [])

  return (
    <div className='authors-nav'>
      <div className='nav-search-form'>
        <SearchForm
          apiSearcher={handleApiSearcher}
          focusEvent='AUTHORS_NAV_CLICKED'
        />
      </div>

      <div className='nav-search-list'>
        { authorsSearchEntries.map(searchEntry => (
          <NavDropdown.Item
            as={InternalLink}
            href={authorPagePath(searchEntry.authorId)}
            key={searchEntry.authorId}
          >
            { searchEntry.label }
          </NavDropdown.Item>)
        ) }
      </div>
    </div>
  )
}

export default AuthorsNavList
