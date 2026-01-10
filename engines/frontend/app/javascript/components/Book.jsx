import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectBookDefaultImageUrl } from 'store/books/selectors'
import { selectCurrentBookId } from 'store/axis/selectors'

import ImageContainer from 'components/ImageContainer'
import UrlStoreContext from 'store/urlStore/Context'

const Book = ({ bookIndexEntry, showYear = false }) => {
  const currentBookId = useSelector(selectCurrentBookId())
  const defaultCoverUrl = useSelector(selectBookDefaultImageUrl())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = bookIndexEntry.id === currentBookId
  const coverUrl = bookIndexEntry.coverUrl || defaultCoverUrl
  const classNames = classnames('book-case', { 'selected': isCurrent })

  useEffect(() => {
    if (isCurrent)  ref.current?.scrollIntoView()
  })

  const handleClick = useCallback(() => {
    showBooksIndexEntry(bookIndexEntry.id)
  }, [bookIndexEntry.id])

  return (
    <div
      className={classNames}
      onClick={handleClick}
      ref={ref}
      title={bookIndexEntry.title}
    >
      <ImageContainer
        classes='book-cover'
        url={coverUrl}
      />

      { showYear ? (
        <div className='year'>
          { bookIndexEntry.year }
        </div>
      ) : null}
    </div>
  )
}

Book.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
  showYear: PropTypes.bool,
}

export default Book
