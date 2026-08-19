import React from 'react'
import { useSelector } from 'react-redux'

import { selectBookIds } from 'widgets/booksListLinear/selectors'
import BookSpine from 'sidebar/booksListLinearControls/BookSpine'

const BooksSpineStack = () => {
  const bookIds = useSelector(selectBookIds())

  if (bookIds.length === 0) return null

  return (
    <div className='books-spine-stack'>
      { bookIds.map(id => (
        <BookSpine
          id={id}
          key={id}
        />
      )) }
    </div>
  )
}

export default BooksSpineStack
