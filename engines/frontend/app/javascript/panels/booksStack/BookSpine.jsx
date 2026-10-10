import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import classnames from 'classnames'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectBooksIndexEntry } from 'store/books/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { coverBackgroundStyle, coverPaletteForId } from 'utils/coverPalettes'

const BookSpine = ({ id, scrollEpoch = 0 }) => {
  const bookIndexEntry = useSelector(selectBooksIndexEntry(id))
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = bookIndexEntry?.id === currentBookId
  const format = bookIndexEntry?.format || 'normal'
  const isSmall = format === 'small'
  const isCollection = format === 'collection'
  const palette = coverPaletteForId(id, { small: isSmall, collection: isCollection })

  useEffect(() => {
    if (!isCurrent) return

    ref.current?.focus({ preventScroll: true })
    ref.current?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [isCurrent, scrollEpoch])

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
      className={classnames('book-spine', `book-spine--${format}`, {
        selected: isCurrent,
      })}
      onClick={handleClick}
      ref={ref}
      style={coverBackgroundStyle(palette, { flat: isSmall })}
      tabIndex={-1}
      title={bookIndexEntry.title}
    >
      <div className='book-spine-body'>
        <span className='book-spine-title'>
          { bookIndexEntry.title }
        </span>

        <span className='book-spine-year'>
          <span className='book-spine-dot' />

          { bookIndexEntry.year }
        </span>
      </div>
    </div>
  )
}

BookSpine.propTypes = {
  id: PropTypes.number.isRequired,
  scrollEpoch: PropTypes.number,
}

export default BookSpine
