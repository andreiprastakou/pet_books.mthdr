import React, { useCallback, useContext, useState } from 'react'
import { useSelector } from 'react-redux'
import { NavDropdown } from 'react-bootstrap'
import PropTypes from 'prop-types'

import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import apiClient from 'store/books/apiClient'
import SearchForm from 'widgets/navbar/components/SearchForm'
import UrlStoreContext from 'store/urlStore/Context'

const BooksNavList = () => {
  const handleApiSearcher = useCallback(key => apiClient.search(key).then(searchEntries => {
    setSearchEntries(searchEntries)
  }), [])

  const [searchEntries, setSearchEntries] = useState([])

  return (
    <div className='books-nav'>
      <div className='nav-search-form'>
        <SearchForm
          apiSearcher={handleApiSearcher}
          focusEvent='BOOKS_NAV_CLICKED'
        />
      </div>

      <div className='nav-search-list'>
        { searchEntries.map(searchEntry => (
          (<SearchEntry
            entry={searchEntry}
            key={searchEntry.bookId}
           />)
        )) }
      </div>
    </div>
  )
}

const SearchEntry = ({ entry }) => {
  const authorRefs = useSelector(selectAuthorsRefsByIds(entry.authorIds))
  const { routes: { booksPagePath } } = useContext(UrlStoreContext)
  return (
    <NavDropdown.Item
      href={booksPagePath({ bookId: entry.bookId })}
      title={`${entry.title} (${entry.year})`}
    >
      <span className='author'>
        { authorRefs.map(authorRef => authorRef.fullname).join(', ') }
      </span>

      { ' ' }

      <span className='title'>
        { entry.title }
      </span>

      { ' ' }

      <span className='year'>
        { `(${entry.year})` }
      </span>
    </NavDropdown.Item>
  )
}

SearchEntry.propTypes = {
  entry: PropTypes.object.isRequired,
}

export default BooksNavList
