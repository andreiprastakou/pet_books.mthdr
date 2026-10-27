import React from 'react'
import PropTypes from 'prop-types'

import BookIndexEntry from 'components/books/BookIndexEntry'
import { coverSizeType } from 'utils/coverSizes'

const BooksListCoversGrid = ({
  bookIds,
  bookLabels,
  coverSize,
  gridRef,
  onSelectBook,
  rowSize,
  selectedBookId,
}) => {
  const rows = [...Array(Math.ceil(bookIds.length / rowSize)).keys()]
    .map(index => bookIds.slice(index * rowSize, (index + 1) * rowSize))

  return (
    <div
      className='books-list-rows'
      ref={gridRef}
    >
      { bookIds.length === 0 ? (
        <div className='books-list-empty'>
          { 'No books' }
        </div>
      ) : rows.map(row => (
        <div
          className='books-list-row'
          key={row.join('-')}
        >
          { row.map(bookId => (
            <BookIndexEntry
              id={bookId}
              key={bookId}
              label={bookLabels ? bookLabels[bookId] || '' : null}
              onSelect={onSelectBook}
              selectedId={onSelectBook ? selectedBookId : null}
              showYear={!bookLabels}
              size={coverSize}
            />
            )) }
        </div>
        )) }
    </div>
  )
}

BooksListCoversGrid.propTypes = {
  bookIds: PropTypes.array.isRequired,
  bookLabels: PropTypes.object,
  coverSize: coverSizeType.isRequired,
  gridRef: PropTypes.object.isRequired,
  onSelectBook: PropTypes.func,
  rowSize: PropTypes.number.isRequired,
  selectedBookId: PropTypes.number,
}

export default BooksListCoversGrid
