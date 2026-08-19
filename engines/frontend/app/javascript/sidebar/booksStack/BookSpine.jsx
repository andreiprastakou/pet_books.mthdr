import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import classnames from 'classnames'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectBooksIndexEntry } from 'store/books/selectors'
import UrlStoreContext from 'store/urlStore/Context'

import { spineBackgroundStyle, spinePaletteForId } from 'sidebar/booksStack/spinePalettes'

const BookSpine = ({ id }) => {
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = bookIndexEntry?.id === currentBookId
  const palette = spinePaletteForId(id)

  useEffect(() => {
    if (isCurrent) ref.current?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [isCurrent])

  const handleClick = useCallback(() => {
    if (!bookIndexEntry) return
    showBooksIndexEntry(bookIndexEntry.id)
  }, [bookIndexEntry, showBooksIndexEntry])

  if (!bookIndexEntry)
    return (
      <div
        className='book-spine book-spine-placeholder'
        ref={ref}
      />
    )

  return (
    <div
      className={classnames('book-spine', { selected: isCurrent })}
      onClick={handleClick}
      ref={ref}
      style={spineBackgroundStyle(palette)}
      title={bookIndexEntry.title}
    >
      <div className='book-spine-trim book-spine-trim-top' />

      <div className='book-spine-body'>
        <span className='book-spine-title'>
          { bookIndexEntry.title }
        </span>

        <span className='book-spine-year'>
          <span className='book-spine-dot' />

          { bookIndexEntry.year }
        </span>
      </div>

      <div className='book-spine-trim book-spine-trim-bottom' />
    </div>
  )
}

BookSpine.propTypes = {
  id: PropTypes.number.isRequired,
}

export default BookSpine
