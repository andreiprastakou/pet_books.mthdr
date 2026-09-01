import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useDispatch } from 'react-redux'
import { Form, Spinner } from 'react-bootstrap'

import { addErrorMessage } from 'store/notifications/actions'
import EventsContext from 'store/events/Context'

const SearchForm = ({ focusEvent = null, apiSearcher }) => {
  const { subscribeToEvent } = useContext(EventsContext)
  const [searchKey, setSearchKey] = useState('')
  const [searchInProgress, setSearchInProgress] = useState(false)
  const searchRef = useRef()
  const dispatch = useDispatch()

  const setFocus = () => setTimeout(() => searchRef.current.focus(), 100)

  useEffect(() => {
    setFocus()
    subscribeToEvent(focusEvent, () => {
      setFocus()
    })
  }, [])

  const performSearch = useCallback(() => {
    const currentKey = searchKey
    if (!currentKey || searchInProgress) return

    setSearchInProgress(true)
    apiSearcher(currentKey).then(() => {
      setSearchInProgress(false)
    }).fail(() => {
      dispatch(addErrorMessage('Search failed!'))
      setSearchInProgress(false)
    })
  }, [apiSearcher, dispatch, searchInProgress, searchKey])

  const handleSearchSubmit = useCallback(e => {
    e.preventDefault()
    performSearch()
  }, [performSearch])

  const handleSearchChange = useCallback(e => {
    setSearchKey(e.target.value)
  }, [])

  return (
    <Form onSubmit={handleSearchSubmit}>
      <Form.Control
        autoComplete='off'
        onChange={handleSearchChange}
        ref={searchRef}
        type='text'
        value={searchKey}
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
