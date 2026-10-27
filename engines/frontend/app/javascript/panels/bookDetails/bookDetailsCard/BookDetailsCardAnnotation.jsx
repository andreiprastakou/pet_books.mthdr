import React from 'react'
import PropTypes from 'prop-types'

const BookDetailsCardAnnotation = ({ book }) => {
  if (!book.summary) return null

  return (
    <div className='book-details-panel-annotation'>
      <p>
        { book.summary }
      </p>

      { book.summarySource ? (
        <div className='description-source'>
          { `(source: ${book.summarySource})` }
        </div>
      ) : null }
    </div>
  )
}

BookDetailsCardAnnotation.propTypes = {
  book: PropTypes.object.isRequired,
}

export default BookDetailsCardAnnotation
