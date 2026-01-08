import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectBooksIndexEntry } from 'store/books/selectors'
import Book from 'components/Book'
import BookPlaceholder from 'components/BookPlaceholder'

const BookIndexEntry = ({ id, showYear = false }) => {
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))

  if (!bookIndexEntry) return <BookPlaceholder id={id} />

  return (
    <Book
      bookIndexEntry={bookIndexEntry}
      showYear={showYear}
    />
  )
}

BookIndexEntry.propTypes = {
  id: PropTypes.number.isRequired,
  showYear: PropTypes.bool,
}

export default BookIndexEntry
