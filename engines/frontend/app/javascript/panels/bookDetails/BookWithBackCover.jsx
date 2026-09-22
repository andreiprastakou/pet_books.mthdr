import React from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import classnames from 'classnames'

import Book from 'components/Book'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { coverBackgroundStyle, coverPaletteForId } from 'utils/coverPalettes'

const BookBackCover = ({ bookId, coverImage, small }) => {
  const usePalette = small || coverImage === 'default'
  const isDefaultCover = coverImage === 'default'

  return (
    <div
      className={classnames('b-cover-standard book-back-cover', {
        'book-back-cover--small': small,
      })}
      data-cover-image={small ? undefined : coverImage}
      style={usePalette
        ? coverBackgroundStyle(coverPaletteForId(bookId, { small }), { flat: small })
        : null}
    >
      { !small ? (
        <div
          className={classnames('b-cover-texture', {
            'b-cover-texture--on-image': !isDefaultCover,
          })}
        />
      ) : null }
    </div>
  )
}

BookBackCover.propTypes = {
  bookId: PropTypes.number.isRequired,
  coverImage: PropTypes.string.isRequired,
  small: PropTypes.bool,
}

const BookWithBackCover = ({ bookIndexEntry }) => {
  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))
  const small = Boolean(bookIndexEntry.small)

  return (
    <>
      { coverDesign || small ? (
        <BookBackCover
          bookId={bookIndexEntry.id}
          coverImage={coverDesign?.coverImage || 'default'}
          small={small}
        />
      ) : null }

      <Book bookIndexEntry={bookIndexEntry} />
    </>
  )
}

BookWithBackCover.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
}

export default BookWithBackCover
