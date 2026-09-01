import React from 'react'
import classnames from 'classnames'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectBookIds } from 'store/booksList/selectors'
import BookSpine from 'panels/booksStack/BookSpine'

const BooksSpineStack = ({ isActive }) => {
  const bookIds = useSelector(selectBookIds())

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
          />
        )) }
      </div>
    </div>
  )
}

BooksSpineStack.propTypes = {
  isActive: PropTypes.bool.isRequired,
}

export default BooksSpineStack
