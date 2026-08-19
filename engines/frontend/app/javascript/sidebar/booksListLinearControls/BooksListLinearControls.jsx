import React from 'react'
import { useSelector } from 'react-redux'
import { Card } from 'react-bootstrap'

import { selectBooksTotal } from 'widgets/booksListLinear/selectors'
import BooksSpineStack from 'sidebar/booksListLinearControls/BooksSpineStack'
import SortingDropdown from 'sidebar/booksListLinearControls/SortingDropdown'

const BooksListControls = () => {
  const totalCount = useSelector(selectBooksTotal())

  return (
    <Card className='sidebar-books-list-linear-controls-widget sidebar-card-widget'>
      <Card.Header className='widget-title books-spine-widget-header'>
        <span className='books-spine-widget-title'>
          { 'Books' }
        </span>

        { totalCount > 0 ? (
          <span className='books-spine-count-badge'>
            { totalCount }
          </span>
        ) : null }

        <SortingDropdown />
      </Card.Header>

      <Card.Body className='books-spine-widget-body'>
        <BooksSpineStack />
      </Card.Body>
    </Card>
  )
}

export default BooksListControls
