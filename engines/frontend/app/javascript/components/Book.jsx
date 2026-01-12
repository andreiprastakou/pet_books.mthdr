import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TITLE_LENGTH_LONG = 25

const Book = ({ bookIndexEntry, showYear = false }) => {
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = bookIndexEntry.id === currentBookId
  const classNames = classnames('book-case', { 'selected': isCurrent })

  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))

  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry.authorIds))

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
      { bookIndexEntry.small ? (
        <BookSmall
          authorRefs={authorRefs}
          bookIndexEntry={bookIndexEntry}
          coverDesign={coverDesign}
        />
      ) : (
        <BookStandard
          authorRefs={authorRefs}
          bookIndexEntry={bookIndexEntry}
          coverDesign={coverDesign}
        />
      ) }

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

const BookStandard = ({ authorRefs, coverDesign, bookIndexEntry }) => (
  <div
    className='b-cover-standard'
    data-cover-image={coverDesign.coverImage}
  >
    <div
      className={classnames('b-standard-cover-title', { 'b-long': bookIndexEntry.title.length > TITLE_LENGTH_LONG })}
      data-font={coverDesign.titleFont}
      data-text-color={coverDesign.titleColor}
    >
      { bookIndexEntry.title }
    </div>

    <div
      className='b-standard-cover-author'
      data-font={coverDesign.authorNameFont}
      data-text-color={coverDesign.authorNameColor}
    >
      { authorRefs.map(authorRef => authorRef.fullname).join(', ') }
    </div>
  </div>
)

BookStandard.propTypes = {
  authorRefs: PropTypes.array.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  coverDesign: PropTypes.object.isRequired,
}

const BookSmall = ({ authorRefs, coverDesign, bookIndexEntry }) => (
  <div
    className='b-cover-standard b-standard-cover-small'
    data-cover-image={coverDesign.coverImage}
  >
    <div className="b-standard-cover-small-text-container">
      <div
        className='b-standard-cover-author'
        data-font='special_elite'
      >
        { authorRefs.map(authorRef => authorRef.fullname).join(', ') }
      </div>

      <div className='b-small-cover-separator' />

      <div
        className={classnames('b-standard-cover-title', { 'b-long': bookIndexEntry.title.length > TITLE_LENGTH_LONG })}
        data-font='special_elite'
      >
        { bookIndexEntry.title }
      </div>
    </div>
  </div>
)

BookSmall.propTypes = {
  authorRefs: PropTypes.array.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  coverDesign: PropTypes.object.isRequired,
}

export default Book
