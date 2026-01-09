import React from 'react'
import { useSelector } from 'react-redux'
import { Card } from 'react-bootstrap'

import {
  selectAuthorsTotal,
} from 'pages/authorsPage/selectors'

import Pagination from 'sidebar/authorsIndexControls/Pagination'
import SortingDropdown from 'sidebar/authorsIndexControls/SortingDropdown'

const AuthorsIndexControls = () => {
  const totalCount = useSelector(selectAuthorsTotal())

  return (
    <Card className='sidebar-authors-index-controls-widget sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { `Authors: ${totalCount}` }
      </Card.Header>

      <Card.Body>
        <SortingDropdown />

        <Pagination />
      </Card.Body>
    </Card>
  )
}

export default AuthorsIndexControls
