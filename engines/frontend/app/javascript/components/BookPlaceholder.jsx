import React from 'react'
import PropTypes from 'prop-types'
import { Spinner } from 'react-bootstrap'

const BookPlaceholder = ({ id, style }) => (
  <div
    className='book-case placeholder'
    style={style}
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
  style: PropTypes.object,
}

export default BookPlaceholder
