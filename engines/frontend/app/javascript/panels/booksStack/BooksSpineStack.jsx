import React from 'react'
import classnames from 'classnames'
import PropTypes from 'prop-types'

import BookSpine from 'panels/booksStack/BookSpine'

const BooksSpineStack = ({ bookIds, isActive, scrollEpoch }) => {
  if (bookIds.length === 0) return null

  return (
    <div className='books-spine-stack-wrap'>
      <div
        className={classnames('books-spine-stack', {
          active: isActive,
        })}
      >
        { bookIds.map(id => (
          <BookSpine
            id={id}
            key={id}
            scrollEpoch={scrollEpoch}
          />
        )) }
      </div>
    </div>
  )
}

BooksSpineStack.propTypes = {
  bookIds: PropTypes.arrayOf(PropTypes.number).isRequired,
  isActive: PropTypes.bool.isRequired,
  scrollEpoch: PropTypes.number.isRequired,
}

export default BooksSpineStack
