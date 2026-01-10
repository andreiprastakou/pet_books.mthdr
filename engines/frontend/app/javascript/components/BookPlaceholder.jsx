import React from 'react'
import PropTypes from 'prop-types'
import { Spinner } from 'react-bootstrap'

const BookPlaceholder = ({ id }) => (
  <div
    className='book-case placeholder'
    title={`ID=${id}`}
  >
    <Spinner
      animation='border'
      className='placeholder-spinner'
    />
  </div>
)

BookPlaceholder.propTypes = {
  id: PropTypes.number.isRequired,
}

export default BookPlaceholder
