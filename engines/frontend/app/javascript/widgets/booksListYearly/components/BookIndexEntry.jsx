import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectBooksIndexEntry } from 'store/books/selectors'
import Book from 'components/Book'
import BookPlaceholder from 'components/BookPlaceholder'
import BookSelected from 'widgets/booksListYearly/components/BookSelected'

const BookIndexEntry = ({ id }) => {
  const currentBookId = useSelector(selectCurrentBookId())
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))

  if (!bookIndexEntry) return <BookPlaceholder id={id} />

  return (
    id === currentBookId ? (
      <BookSelected bookIndexEntry={bookIndexEntry} />
    ) : (
      <Book bookIndexEntry={bookIndexEntry} />
    )
  )
}

BookIndexEntry.propTypes = {
  id: PropTypes.number.isRequired,
}

export default BookIndexEntry
