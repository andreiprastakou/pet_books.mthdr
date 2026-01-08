import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useDispatch } from 'react-redux'
import { Form, Spinner } from 'react-bootstrap'

import { addErrorMessage } from 'widgets/notifications/actions'
import EventsContext from 'store/events/Context'

const SearchForm = ({ focusEvent = null, apiSearcher }) => {
  const { subscribeToEvent } = useContext(EventsContext)
  const [searchState, setSearchState] = useState({})
  const { lastSearchedKey = null, searchInProgress = false } = searchState
  const searchKey = useRef(null)
  const key = searchKey.current
  const searchRef = useRef()
  const dispatch = useDispatch()

  const setFocus = () => setTimeout(() => searchRef.current.focus(), 100)

  useEffect(() => {
    setFocus()
    subscribeToEvent(focusEvent, () => {
      setFocus()
    })
  }, [])

  const performSearch = () => {
    if (!key || searchInProgress) return

    setSearchState({ searchInProgress: true })
    apiSearcher(key).then(() => {
      setSearchState({ searchInProgress: false, lastSearchedKey: key })
    }).fail(() => {
      dispatch(addErrorMessage('Search failed!'))
      setSearchState({ searchInProgress: false })
    })
  }

  const handleSearchSubmit = useCallback(e => {
    e.preventDefault()
    performSearch()
  }, [])

  const handleChange = useCallback(e => {
    searchKey.current = e.target.value
    setTimeout(() => {
      if (key !== searchKey.current || key === lastSearchedKey) return
      performSearch()
    }, 1000)
  }, [])

  return (
    <Form onSubmit={handleSearchSubmit}>
      <Form.Control
        autoComplete='off'
        onChange={handleChange}
        ref={searchRef}
        type='text'
      />

      { searchInProgress ? (
        <Spinner
          animation='border'
          className='search-spinner'
        />
      ) : null }
    </Form>
  )
}

SearchForm.propTypes = {
  apiSearcher: PropTypes.func.isRequired,
  focusEvent: PropTypes.string,
}

export default SearchForm
