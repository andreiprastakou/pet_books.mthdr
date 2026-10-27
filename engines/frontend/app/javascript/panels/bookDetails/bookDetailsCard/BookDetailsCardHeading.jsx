import React from 'react'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

const BookDetailsCardHeading = ({ book, booksPagePath }) => (
  <div className='book-details-panel-heading'>
    <h2>
      { book.title }
    </h2>

    <span>
      <InternalLink href={booksPagePath({ bookId: book.id })}>
        { book.yearPublished }
      </InternalLink>
    </span>
  </div>
)

BookDetailsCardHeading.propTypes = {
  book: PropTypes.object.isRequired,
  booksPagePath: PropTypes.func.isRequired,
}

export default BookDetailsCardHeading
