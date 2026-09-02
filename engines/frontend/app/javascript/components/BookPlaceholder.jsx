import React from 'react'
import PropTypes from 'prop-types'
import { Spinner } from 'react-bootstrap'
import classnames from 'classnames'

import { DEFAULT_COVER_SIZE, coverSizeClass, coverSizeType } from 'utils/coverSizes'

const BookPlaceholder = ({ id, size = DEFAULT_COVER_SIZE, style }) => (
  <div
    className={classnames('book-case', 'placeholder', coverSizeClass(size))}
    style={style}
    title={`ID=${id}`}
  >
    <div className='b-cover-placeholder'>
      <Spinner
        animation='border'
        className='placeholder-spinner'
      />
    </div>
  </div>
)

BookPlaceholder.propTypes = {
  id: PropTypes.number.isRequired,
  size: coverSizeType,
  style: PropTypes.object,
}

export default BookPlaceholder
