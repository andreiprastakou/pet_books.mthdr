import React, { useCallback, useContext } from 'react'
import { useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import PropTypes from 'prop-types'
import { faBookmark } from '@fortawesome/free-solid-svg-icons/faBookmark'
import { faUserNinja } from '@fortawesome/free-solid-svg-icons/faUserNinja'
import { faBookmark as faBookmarkEmpty } from '@fortawesome/free-regular-svg-icons/faBookmark'
import { faUser } from '@fortawesome/free-regular-svg-icons/faUser'

import { addSuccessMessage } from 'store/notifications/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BookToolbar = ({ bookPageHref }) => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)

  const isBookmarked = false
  const isRead = false

  const handleClick = useCallback(() => {
    dispatch(addSuccessMessage('Dev note: not implemented!'))
  }, [dispatch])
  const copyBookPageLink = useCallback(event => {
    event.preventDefault()
    const absoluteBookPageHref = new URL(bookPageHref, window.location.origin).href
    navigator.clipboard.writeText(absoluteBookPageHref)
    dispatch(addSuccessMessage('Link copied to clipboard!'))
  }, [bookPageHref, dispatch])

  if (!routesReady) return null

  return (
    <div>
      <ButtonGroup className='book-toolbar'>
        { isBookmarked ?
          <Button
            onClick={handleClick}
            title='Remove bookmark'
            type='button'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faBookmark} />
          </Button>
          :
          <Button
            onClick={handleClick}
            title='Bookmark'
            type='button'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faBookmarkEmpty} />
          </Button>}

        { isRead ?
          <Button
            onClick={handleClick}
            title='Mark as not read'
            type='button'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faUserNinja} />
          </Button>
          :
          <Button
            onClick={handleClick}
            title='Mark as read'
            type='button'
            variant='outline-warning'
          >
            <FontAwesomeIcon icon={faUser} />
          </Button>}

        <Button
          as='a'
          className='internal-link'
          href={bookPageHref}
          onClick={copyBookPageLink}
          title='Copy book page link'
          variant='outline-primary'
        >
          <FontAwesomeIcon icon={faLink} />
        </Button>

      </ButtonGroup>
    </div>
  )
}

BookToolbar.propTypes = {
  bookPageHref: PropTypes.string.isRequired,
}

export default BookToolbar
