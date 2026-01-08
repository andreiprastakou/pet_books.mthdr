import React, { useCallback, useContext } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBookmark, faUserNinja } from '@fortawesome/free-solid-svg-icons'
import { faBookmark as faBookmarkEmpty, faCalendarAlt, faUser } from '@fortawesome/free-regular-svg-icons'
import { faGoodreadsG } from '@fortawesome/free-brands-svg-icons'
import PropTypes from 'prop-types'

import {
  selectTagBookmark,
  selectTagRead,
  selectTagNames,
} from 'store/tags/selectors'

import { addTagToBook, removeTagFromBook } from 'widgets/booksListYearly/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BookToolbar = props => {
  const { book } = props
  const dispatch = useDispatch()
  const { routesReady,
    routes: { booksPagePath } } = useContext(UrlStoreContext)
  const tagNames = useSelector(selectTagNames(book.tagIds))

  const tagBookmark = useSelector(selectTagBookmark())
  const isBookmarked = tagNames.includes(tagBookmark)
  const tagRead = useSelector(selectTagRead())
  const isRead = tagNames.includes(tagRead)

  const handleClickUnbookmark = useCallback(() => {
    dispatch(removeTagFromBook(book.id, tagBookmark))
  }, [book.id, tagBookmark])

  const handleClickBookmark = useCallback(() => {
    dispatch(addTagToBook(book.id, tagBookmark))
  }, [book.id, tagBookmark])

  const handleClickMarkAsNotRead = useCallback(() => {
    dispatch(removeTagFromBook(book.id, tagRead))
  }, [book.id, tagRead])

  const handleClickMarkAsRead = useCallback(() => {
    dispatch(addTagToBook(book.id, tagRead))
  }, [book.id, tagRead])

  if (!routesReady) return null

  return (
    <div>
      <ButtonGroup className='book-toolbar'>
        { book.goodreadsUrl ? (
          <Button
            href={book.goodreadsUrl}
            target='_blank'
            title='See info...'
            variant='outline-info'
          >
            <FontAwesomeIcon icon={faGoodreadsG} />
          </Button>
        ) : null }

        <Button
          href={booksPagePath({ bookId: book.id })}
          title='See what was then...'
          variant='outline-info'
        >
          <FontAwesomeIcon icon={faCalendarAlt} />
        </Button>

        { isBookmarked ?
          <Button
            href='#'
            onClick={handleClickUnbookmark}
            title='Remove bookmark'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faBookmark} />
          </Button>
          :
          <Button
            href='#'
            onClick={handleClickBookmark}
            title='Bookmark'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faBookmarkEmpty} />
          </Button>}

        { isRead ?
          <Button
            href='#'
            onClick={handleClickMarkAsNotRead}
            title='Mark as not read'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faUserNinja} />
          </Button>
          :
          <Button
            href='#'
            onClick={handleClickMarkAsRead}
            title='Mark as read'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faUser} />
          </Button>}

      </ButtonGroup>
    </div>
  )
}

BookToolbar.propTypes = {
  book: PropTypes.object.isRequired,
}

export default BookToolbar
