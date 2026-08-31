import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Dropdown } from 'react-bootstrap'
import PropTypes from 'prop-types'

import UrlStoreContext from 'store/urlStore/Context'

const SortingDropdown = ({ selectSortBy, sortOptions }) => {
  const currentValue = useSelector(selectSortBy())
  const { actions: { switchToIndexSort } } = useContext(UrlStoreContext)

  const handleSortClick = useCallback(value => e => {
    e.preventDefault()
    switchToIndexSort(value)
  }, [switchToIndexSort])

  return (
    <Dropdown className='list-sort-dropdown'>
      <Dropdown.Toggle variant='secondary'>
        { `Sort by: ${currentValue}` }
      </Dropdown.Toggle>

      <Dropdown.Menu>
        { sortOptions.map(value => (
          <Dropdown.Item
            disabled={currentValue === value}
            key={value}
            onClick={handleSortClick(value)}
          >
            { value }
          </Dropdown.Item>
        )) }
      </Dropdown.Menu>
    </Dropdown>
  )
}

SortingDropdown.propTypes = {
  selectSortBy: PropTypes.func.isRequired,
  sortOptions: PropTypes.arrayOf(PropTypes.string).isRequired,
}

export default SortingDropdown
