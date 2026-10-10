import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { shallowEqual, useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { DEFAULT_COVER_SIZE, coverSizeClass, coverSizeType } from 'utils/coverSizes'
import {
  FORMAT_COLLECTION,
  FORMAT_NORMAL,
  FORMAT_SMALL,
  coverBackgroundStyle,
  coverPaletteForId,
} from 'utils/coverPalettes'

const TITLE_LENGTH_LONG = 25

const Book = ({
  bookIndexEntry,
  label,
  onSelect = null,
  scrollIntoView = true,
  selectedId = null,
  showYear = false,
  size = DEFAULT_COVER_SIZE,
  style,
}) => {
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = onSelect
    ? bookIndexEntry.id === selectedId
    : bookIndexEntry.id === currentBookId
  const classNames = classnames('book-case', coverSizeClass(size), { 'selected': isCurrent })

  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))

  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry.authorIds), shallowEqual)

  useEffect(() => {
    if (isCurrent && scrollIntoView) ref.current?.scrollIntoView()
  }, [isCurrent, scrollIntoView])

  const handleClick = useCallback(() => {
    if (onSelect) onSelect(bookIndexEntry.id)
    else if (showBooksIndexEntry) showBooksIndexEntry(bookIndexEntry.id)
  }, [bookIndexEntry.id, onSelect, showBooksIndexEntry])

  return (
    <div
      className={classNames}
      onClick={handleClick}
      ref={ref}
      style={style}
      title={bookIndexEntry.title}
    >
      { bookIndexEntry.format === FORMAT_SMALL ? (
        <BookSmall
          authorRefs={authorRefs}
          bookIndexEntry={bookIndexEntry}
        />
      ) : (
        <BookStandard
          authorRefs={authorRefs}
          bookIndexEntry={bookIndexEntry}
          coverDesign={coverDesign}
        />
      ) }

      { label === null && showYear ? (
        <div className='year'>
          { bookIndexEntry.year }
        </div>
      ) : null }

      { label !== null && (
        <div
          className='book-label'
          title={label}
        >
          { label }
        </div>
      ) }
    </div>
  )
}

Book.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
  label: PropTypes.string,
  onSelect: PropTypes.func,
  scrollIntoView: PropTypes.bool,
  selectedId: PropTypes.number,
  showYear: PropTypes.bool,
  size: coverSizeType,
  style: PropTypes.object,
}

const BookStandard = ({ authorRefs, coverDesign, bookIndexEntry }) => {
  const format = bookIndexEntry.format || FORMAT_NORMAL
  const isCollection = format === FORMAT_COLLECTION
  const isDefaultCover = isCollection || coverDesign.coverImage === 'default'

  return (
    <div
      className={classnames('b-cover-standard', `b-standard-cover--${format}`)}
      data-cover-image={isCollection ? 'default' : coverDesign.coverImage}
      style={isDefaultCover
        ? coverBackgroundStyle(coverPaletteForId(bookIndexEntry.id, format))
        : null}
    >
      <div
        className={classnames('b-cover-texture', {
          'b-cover-texture--on-image': !isDefaultCover,
        })}
      />

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
}

BookStandard.propTypes = {
  authorRefs: PropTypes.array.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  coverDesign: PropTypes.object.isRequired,
}

const BookSmall = ({ authorRefs, bookIndexEntry }) => (
  <div
    className={`b-cover-standard b-standard-cover--${FORMAT_SMALL}`}
    style={coverBackgroundStyle(coverPaletteForId(bookIndexEntry.id, FORMAT_SMALL), { flat: true })}
  >
    <div className='b-cover-texture' />

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
}

export default Book
