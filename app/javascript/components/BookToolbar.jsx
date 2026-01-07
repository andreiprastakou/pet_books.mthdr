import React, { useContext } from 'react'
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

const BookToolbar = (props) => {
  const { book } = props
  const dispatch = useDispatch()
  const { routesReady,
          routes: { booksPagePath } } = useContext(UrlStoreContext)
  const tagNames = useSelector(selectTagNames(book.tagIds))

  const tagBookmark = useSelector(selectTagBookmark())
  const isBookmarked = tagNames.includes(tagBookmark)
  const tagRead = useSelector(selectTagRead())
  const isRead = tagNames.includes(tagRead)

  if (!routesReady) return null

  return (
    <div>
      <ButtonGroup className='book-toolbar'>
        { book.goodreadsUrl &&
          <Button variant='outline-info' title='See info...' href={ book.goodreadsUrl } target='_blank'>
            <FontAwesomeIcon icon={ faGoodreadsG }/>
          </Button>
        }

        <Button variant='outline-info' title='See what was then...' href={ booksPagePath({ bookId: book.id }) }>
          <FontAwesomeIcon icon={ faCalendarAlt }/>
        </Button>

        { isBookmarked ?
          <Button variant='outline-warning' title='Remove bookmark' href='#'
                  onClick={ () => dispatch(removeTagFromBook(book.id, tagBookmark)) }>
            <FontAwesomeIcon icon={ faBookmark }/>
          </Button>
          :
          <Button variant='outline-warning' title='Bookmark' href='#'
                  onClick={ () => dispatch(addTagToBook(book.id, tagBookmark)) }>
            <FontAwesomeIcon icon={ faBookmarkEmpty }/>
          </Button>
        }

        { isRead ?
            <Button variant='outline-warning' title='Mark as not read' href='#'
                    onClick={ () => dispatch(removeTagFromBook(book.id, tagRead)) }>
              <FontAwesomeIcon icon={ faUserNinja }/>
            </Button>
          :
            <Button variant='outline-warning' title='Mark as read' href='#'
                    onClick={ () => dispatch(addTagToBook(book.id, tagRead)) }>
              <FontAwesomeIcon icon={ faUser }/>
            </Button>
        }

      </ButtonGroup>
    </div>
  )
}

BookToolbar.propTypes = {
  book: PropTypes.object.isRequired,
}

export default BookToolbar
