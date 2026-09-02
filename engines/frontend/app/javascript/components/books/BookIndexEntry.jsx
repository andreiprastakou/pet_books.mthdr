import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectBooksIndexEntry } from 'store/books/selectors'
import Book from 'components/Book'
import BookPlaceholder from 'components/BookPlaceholder'
import { DEFAULT_COVER_SIZE, coverSizeType } from 'utils/coverSizes'

const BookIndexEntry = ({
  id, label = null, scrollIntoView = true, showYear = false, size = DEFAULT_COVER_SIZE, style,
}) => {
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))

  if (!bookIndexEntry) return (
    <BookPlaceholder
      id={id}
      size={size}
      style={style}
    />
  )

  return (
    <Book
      bookIndexEntry={bookIndexEntry}
      label={label}
      scrollIntoView={scrollIntoView}
      showYear={showYear}
      size={size}
      style={style}
    />
  )
}

BookIndexEntry.propTypes = {
  id: PropTypes.number.isRequired,
  label: PropTypes.string,
  scrollIntoView: PropTypes.bool,
  showYear: PropTypes.bool,
  size: coverSizeType,
  style: PropTypes.object,
}

export default BookIndexEntry
