import React from 'react'
import { useSelector } from 'react-redux'
import { Card } from 'react-bootstrap'

import {
  selectBooksTotal,
} from 'widgets/booksListLinear/selectors'

import Pagination from 'sidebar/booksListLinearControls/Pagination'
import SortingDropdown from 'sidebar/booksListLinearControls/SortingDropdown'

const BooksListControls = () => {
  const totalCount = useSelector(selectBooksTotal())

  return (
    <Card className='sidebar-books-list-linear-controls-widget sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { `Books: ${totalCount}` }
      </Card.Header>

      <Card.Body>
        <SortingDropdown />

        <Pagination />
      </Card.Body>
    </Card>
  )
}

export default BooksListControls
