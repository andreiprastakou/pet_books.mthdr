import React from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import classnames from 'classnames'

import Book from 'components/Book'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import {
  FORMAT_COLLECTION,
  FORMAT_NORMAL,
  FORMAT_SMALL,
  coverBackgroundStyle,
  coverPaletteForId,
} from 'utils/coverPalettes'

const BookBackCover = ({ bookId, coverImage, format }) => {
  const isSmall = format === FORMAT_SMALL
  const isCollection = format === FORMAT_COLLECTION
  const usePalette = isSmall || isCollection || coverImage === 'default'
  const isDefaultCover = isCollection || coverImage === 'default'
  const shownCoverImage = isCollection ? 'default' : coverImage
  const palette = coverPaletteForId(bookId, format)

  return (
    <div
      className={classnames('b-cover-standard book-back-cover', `book-back-cover--${format}`)}
      data-cover-image={isSmall ? null : shownCoverImage}
      style={usePalette ? coverBackgroundStyle(palette, { flat: isSmall }) : null}
    >
      { isSmall ? null : (
        <div
          className={classnames('b-cover-texture', {
            'b-cover-texture--on-image': !isDefaultCover,
          })}
        />
      ) }
    </div>
  )
}

BookBackCover.propTypes = {
  bookId: PropTypes.number.isRequired,
  coverImage: PropTypes.string.isRequired,
  format: PropTypes.string.isRequired,
}

const BookWithBackCover = ({ bookIndexEntry }) => {
  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))
  const format = bookIndexEntry.format || FORMAT_NORMAL
  const isSmall = format === FORMAT_SMALL

  return (
    <>
      { coverDesign || isSmall ? (
        <BookBackCover
          bookId={bookIndexEntry.id}
          coverImage={coverDesign?.coverImage || 'default'}
          format={format}
        />
      ) : null }

      <Book
        bookIndexEntry={bookIndexEntry}
        scrollIntoView={false}
      />
    </>
  )
}

BookWithBackCover.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
}

export default BookWithBackCover
