import React from 'react'
import PropTypes from 'prop-types'
import PopularityChart from 'widgets/booksListLinear/components/PopularityChart'
import BookIndexEntry from 'widgets/booksListLinear/components/BookIndexEntry'

const BooksRow = ({ ids: bookIds }) => (
  <div className='books-list-row'>
    <PopularityChart bookIds={bookIds} />

    <div>
      { bookIds.map(bookId =>
        (<BookIndexEntry
          id={bookId}
          key={bookId}
          showYear
         />)
      ) }
    </div>
  </div>
)

BooksRow.propTypes = {
  ids: PropTypes.array.isRequired,
}

export default BooksRow
