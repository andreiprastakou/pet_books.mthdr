import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { shallowEqual, useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { coverAuthorLine, coverTitle, TITLE_LENGTH_LONG } from 'utils/coverCopy'
import { DEFAULT_COVER_SIZE, coverSizeClass, coverSizeType } from 'utils/coverSizes'
import {
  FORMAT_COLLECTION,
  FORMAT_NORMAL,
  FORMAT_SMALL,
  coverBackgroundStyle,
  coverPaletteForId,
} from 'utils/coverPalettes'

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
          size={size}
        />
      ) : (
        <BookStandard
          authorRefs={authorRefs}
          bookIndexEntry={bookIndexEntry}
          coverDesign={coverDesign}
          size={size}
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

const ReadMark = ({ read }) => {
  if (!read) return null

  return (
    <span
      aria-label='Read'
      className='book-read-mark'
      role='img'
    />
  )
}

ReadMark.propTypes = {
  read: PropTypes.bool,
}

const coverCopyFor = (bookIndexEntry, authorRefs, format, size) => {
  const names = authorRefs.map(authorRef => authorRef?.fullname)
  return {
    author: coverAuthorLine(names, { format, size }),
    longTitle: bookIndexEntry.title.length > TITLE_LENGTH_LONG,
    title: coverTitle(bookIndexEntry.title, { format, size }),
  }
}

const BookStandard = ({ authorRefs, coverDesign, bookIndexEntry, size }) => {
  const format = bookIndexEntry.format || FORMAT_NORMAL
  const isCollection = format === FORMAT_COLLECTION
  const isDefaultCover = isCollection || coverDesign.coverImage === 'default'
  const copy = coverCopyFor(bookIndexEntry, authorRefs, format, size)

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

      <ReadMark read={bookIndexEntry.read} />

      <div
        className={classnames('b-standard-cover-title', { 'b-long': copy.longTitle })}
        data-font={coverDesign.titleFont}
        data-text-color={coverDesign.titleColor}
      >
        { copy.title }
      </div>

      { copy.author ? (
        <div
          className={classnames('b-standard-cover-author', { 'b-tight': copy.author.tight })}
          data-font={coverDesign.authorNameFont}
          data-text-color={coverDesign.authorNameColor}
        >
          { copy.author.text }
        </div>
      ) : null }
    </div>
  )
}

BookStandard.propTypes = {
  authorRefs: PropTypes.array.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  coverDesign: PropTypes.object.isRequired,
  size: coverSizeType.isRequired,
}

const BookSmall = ({ authorRefs, bookIndexEntry, size }) => {
  const copy = coverCopyFor(bookIndexEntry, authorRefs, FORMAT_SMALL, size)

  return (
    <div
      className={`b-cover-standard b-standard-cover--${FORMAT_SMALL}`}
      style={coverBackgroundStyle(coverPaletteForId(bookIndexEntry.id, FORMAT_SMALL), { flat: true })}
    >
      <div className='b-cover-texture' />

      <ReadMark read={bookIndexEntry.read} />

      <div className="b-standard-cover-small-text-container">
        { copy.author ? (
          <>
            <div
              className={classnames('b-standard-cover-author', { 'b-tight': copy.author.tight })}
              data-font='special_elite'
            >
              { copy.author.text }
            </div>

            <div className='b-small-cover-separator' />
          </>
        ) : null }

        <div
          className={classnames('b-standard-cover-title', { 'b-long': copy.longTitle })}
          data-font='special_elite'
        >
          { copy.title }
        </div>
      </div>
    </div>
  )
}

BookSmall.propTypes = {
  authorRefs: PropTypes.array.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  size: coverSizeType.isRequired,
}

export default Book
