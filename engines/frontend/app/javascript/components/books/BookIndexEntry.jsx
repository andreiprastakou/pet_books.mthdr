import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectBooksIndexEntry } from 'store/books/selectors'
import Book from 'components/Book'
import BookPlaceholder from 'components/BookPlaceholder'

const BookIndexEntry = ({
  id, label = null, scrollIntoView = true, showYear = false, style,
}) => {
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))

  if (!bookIndexEntry) return (
    <BookPlaceholder
      id={id}
      style={style}
    />
  )

  return (
    <Book
      bookIndexEntry={bookIndexEntry}
      label={label}
      scrollIntoView={scrollIntoView}
      showYear={showYear}
      style={style}
    />
  )
}

BookIndexEntry.propTypes = {
  id: PropTypes.number.isRequired,
  label: PropTypes.string,
  scrollIntoView: PropTypes.bool,
  showYear: PropTypes.bool,
  style: PropTypes.object,
}

export default BookIndexEntry
