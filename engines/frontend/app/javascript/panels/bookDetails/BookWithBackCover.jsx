import React from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import Book from 'components/Book'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { coverBackgroundStyle, coverPaletteForId } from 'utils/coverPalettes'

const BookBackCover = ({ bookId, coverImage }) => (
  <div
    className='b-cover-standard book-back-cover'
    data-cover-image={coverImage}
    style={coverImage === 'default' ? coverBackgroundStyle(coverPaletteForId(bookId)) : null}
  >
    { coverImage === 'default' ? <div className='b-cover-texture' /> : null }
  </div>
)

BookBackCover.propTypes = {
  bookId: PropTypes.number.isRequired,
  coverImage: PropTypes.string.isRequired,
}

const BookWithBackCover = ({ bookIndexEntry }) => {
  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))

  return (
    <>
      { coverDesign ? (
        <BookBackCover
          bookId={bookIndexEntry.id}
          coverImage={coverDesign.coverImage}
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
