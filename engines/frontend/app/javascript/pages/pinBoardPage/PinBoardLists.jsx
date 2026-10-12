import React, { useContext } from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import PinList, { PinEntry } from 'pages/pinBoardPage/PinList'
import { selectPinBoard } from 'store/pinBoard/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const bookLabel = book => `${book.title} (${book.year}) ${book.authors}`

const BookPinLabel = ({ book }) => (
  <>
    <span className='pin-board-book-title'>
      { book.title }
    </span>

    { ' (' }

    <span className='pin-board-book-year'>
      { book.year }
    </span>

    { ') ' }

    <span className='pin-board-book-authors'>
      { book.authors }
    </span>
  </>
)

BookPinLabel.propTypes = {
  book: PropTypes.object.isRequired,
}

const PinBoardLists = () => {
  const { authors, books, series } = useSelector(selectPinBoard())
  const { routes: { authorPagePath, bookPagePath, seriesPagePath }, routesReady } = useContext(UrlStoreContext)

  return (
    <div className='pin-board-lists'>
      <PinList label='Authors'>
        { routesReady ? authors.map(author => (
          <PinEntry
            href={authorPagePath(author.id)}
            key={author.id}
            title={author.fullname}
          >
            { author.fullname }
          </PinEntry>
        )) : null }
      </PinList>

      <PinList label='Books'>
        { routesReady ? books.map(book => (
          <PinEntry
            href={bookPagePath(book.id)}
            key={book.id}
            title={bookLabel(book)}
          >
            <BookPinLabel book={book} />
          </PinEntry>
        )) : null }
      </PinList>

      <PinList label='Series'>
        { routesReady ? series.map(entry => (
          <PinEntry
            href={seriesPagePath(entry.id)}
            key={entry.id}
            title={entry.name}
          >
            { entry.name }
          </PinEntry>
        )) : null }
      </PinList>
    </div>
  )
}

export default PinBoardLists
