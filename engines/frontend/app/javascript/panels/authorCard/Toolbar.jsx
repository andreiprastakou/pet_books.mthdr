import React, { useCallback, useContext } from 'react'
import { useDispatch } from 'react-redux'
import { Button } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBook } from '@fortawesome/free-solid-svg-icons/faBook'
import { faBookmark } from '@fortawesome/free-solid-svg-icons/faBookmark'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import { faBookmark as faBookmarkEmpty } from '@fortawesome/free-regular-svg-icons/faBookmark'
import PropTypes from 'prop-types'

import { addSuccessMessage } from 'store/notifications/actions'
import UrlStoreContext from 'store/urlStore/Context'

const Toolbar = props => {
  const { authorFull, linkToAuthorPage = true } = props
  const { routes: { authorPagePath },
    routesReady } = useContext(UrlStoreContext)
  const dispatch = useDispatch()

  const isBookmarked = false

  const handleBookmark = useCallback(() => {
    dispatch(addSuccessMessage('Dev note: not implemented!'))
  }, [dispatch])

  if (!routesReady) return null

  return (
    <div className='author-toolbar'>
      { authorFull.reference ? (
        <Button
          className='external-link'
          href={authorFull.reference}
          target='_blank'
          title='See info...'
          variant='outline-secondary'
        >
          { 'wikipedia' }

          <FontAwesomeIcon
            className='external-link-icon'
            icon={faLink}
          />
        </Button>
      ) : null}

      { linkToAuthorPage && authorFull.booksCount > 0 ? (
        <Button
          className='internal-link'
          href={authorPagePath(authorFull.id)}
          title='See all books'
          variant='outline-info'
        >
          <FontAwesomeIcon icon={faBook} />

          { ` (${authorFull.booksCount})` }
        </Button>
      ) : null }

      { isBookmarked ? (
        <Button
          onClick={handleBookmark}
          title='Remove bookmark'
          type='button'
          variant='outline-warning'
        >
          <FontAwesomeIcon icon={faBookmark} />
        </Button>
      ) : (
        <Button
          onClick={handleBookmark}
          title='Bookmark'
          type='button'
          variant='outline-warning'
        >
          <FontAwesomeIcon icon={faBookmarkEmpty} />
        </Button>
      ) }
    </div>
  )
}

Toolbar.propTypes = {
  authorFull: PropTypes.object.isRequired,
  linkToAuthorPage: PropTypes.bool,
}

export default Toolbar
