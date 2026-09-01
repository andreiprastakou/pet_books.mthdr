import React, { useCallback, useContext } from 'react'
import { useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBookmark } from '@fortawesome/free-solid-svg-icons/faBookmark'
import { faUserNinja } from '@fortawesome/free-solid-svg-icons/faUserNinja'
import { faBookmark as faBookmarkEmpty } from '@fortawesome/free-regular-svg-icons/faBookmark'
import { faUser } from '@fortawesome/free-regular-svg-icons/faUser'

import { addSuccessMessage } from 'store/notifications/actions'
import UrlStoreContext from 'store/urlStore/Context'

const BookToolbar = () => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)

  const isBookmarked = false
  const isRead = false

  const handleClick = useCallback(() => {
    dispatch(addSuccessMessage('Dev note: not implemented!'))
  }, [dispatch])

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

      </ButtonGroup>
    </div>
  )
}
export default BookToolbar
