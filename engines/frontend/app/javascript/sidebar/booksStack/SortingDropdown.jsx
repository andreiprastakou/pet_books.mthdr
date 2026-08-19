import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Dropdown } from 'react-bootstrap'

import { selectSortBy } from 'widgets/booksListLinear/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const SORT_OPTIONS = ['popularity', 'year', 'random', 'name']

const SortingDropdown = () => {
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
        { SORT_OPTIONS.map(value => (
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

export default SortingDropdown
