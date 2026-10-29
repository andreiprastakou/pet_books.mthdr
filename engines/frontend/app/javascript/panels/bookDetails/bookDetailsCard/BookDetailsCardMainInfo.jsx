import React, { useCallback } from 'react'
import PropTypes from 'prop-types'

import BookDetailsCardAnnotation from 'panels/bookDetails/bookDetailsCard/BookDetailsCardAnnotation'
import BookDetailsCardHeading from 'panels/bookDetails/bookDetailsCard/BookDetailsCardHeading'
import BookDetailsCardLinkedNames from 'panels/bookDetails/bookDetailsCard/BookDetailsCardLinkedNames'

const BookDetailsCardMainInfo = ({
  authorPagePath,
  authorRefs,
  book,
  booksPagePath,
  seriesPagePath,
  seriesRefs,
  showAuthors = true,
  showSummary,
}) => {
  const authorHref = useCallback(
    author => authorPagePath(author.id, { bookId: book.id }),
    [authorPagePath, book.id]
  )
  const seriesHref = useCallback(
    series => seriesPagePath(series.id, { bookId: book.id }),
    [book.id, seriesPagePath]
  )

  return (
    <div className='book-details-panel-main-info'>
      <BookDetailsCardHeading
        book={book}
        booksPagePath={booksPagePath}
      />

      { book.formLabel ? (
        <div className='book-details-panel-form-label'>
          { book.formLabel }
        </div>
      ) : null }

      { showAuthors ? (
        <div className='book-details-panel-authors'>
          { 'by ' }

          <BookDetailsCardLinkedNames
            buildHref={authorHref}
            entries={authorRefs}
          />
        </div>
      ) : null }

      { seriesRefs.length > 0 ? (
        <div className='book-details-panel-series'>
          { 'from series ' }

          <BookDetailsCardLinkedNames
            buildHref={seriesHref}
            entries={seriesRefs}
          />
        </div>
      ) : null }

      { showSummary ? <BookDetailsCardAnnotation book={book} /> : null }
    </div>
  )
}

BookDetailsCardMainInfo.propTypes = {
  authorPagePath: PropTypes.func.isRequired,
  authorRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  book: PropTypes.object.isRequired,
  booksPagePath: PropTypes.func.isRequired,
  seriesPagePath: PropTypes.func.isRequired,
  seriesRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  showAuthors: PropTypes.bool,
  showSummary: PropTypes.bool.isRequired,
}

export default BookDetailsCardMainInfo
