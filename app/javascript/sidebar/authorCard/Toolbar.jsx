import React, { useCallback, useContext } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBook, faBookmark } from '@fortawesome/free-solid-svg-icons'
import { faBookmark as faBookmarkEmpty } from '@fortawesome/free-regular-svg-icons'
import { faWikipediaW } from '@fortawesome/free-brands-svg-icons'
import PropTypes from 'prop-types'

import { selectTagBookmark, selectTagNames } from 'store/tags/selectors'
import { markAuthorAsBookmarked, unmarkAuthorAsBookmarked } from 'sidebar/authorCard/actions'
import UrlStoreContext from 'store/urlStore/Context'

const Toolbar = props => {
  const { authorFull } = props
  const { routes: { authorPagePath },
    routesReady } = useContext(UrlStoreContext)

  const dispatch = useDispatch()
  const tagNames = useSelector(selectTagNames(authorFull.tagIds))
  const tagBookmark = useSelector(selectTagBookmark())
  const isBookmarked = tagNames.includes(tagBookmark)

  if (!routesReady) return null

  const handleRemoveBookmark = useCallback(() => {
    dispatch(unmarkAuthorAsBookmarked(authorFull.id, authorFull.tagIds))
  }, [authorFull.id, authorFull.tagIds])

  const handleBookmark = useCallback(() => {
    dispatch(markAuthorAsBookmarked(authorFull.id, authorFull.tagIds))
  }, [authorFull.id, authorFull.tagIds])

  return (
    <ButtonGroup className='author-toolbar'>
      { authorFull.reference ? (
        <Button
          href={authorFull.reference}
          target='_blank'
          title='See info...'
          variant='outline-info'
        >
          <FontAwesomeIcon icon={faWikipediaW} />
        </Button>
      ) : null}

      { authorFull.booksCount > 0 &&
      <Button
        href={authorPagePath(authorFull.id)}
        title='See all books'
        variant='outline-info'
      >
        <FontAwesomeIcon icon={faBook} />

        { ` (${authorFull.booksCount})` }
      </Button>}

      { isBookmarked ? (
        <Button
          href='#'
          onClick={handleRemoveBookmark}
          title='Remove bookmark'
          variant='outline-warning'
        >
          <FontAwesomeIcon icon={faBookmark} />
        </Button>
      ) : (
        <Button
          href='#'
          onClick={handleBookmark}
          title='Bookmark'
          variant='outline-warning'
        >
          <FontAwesomeIcon icon={faBookmarkEmpty} />
        </Button>
      ) }
    </ButtonGroup>
  )
}

Toolbar.propTypes = {
  authorFull: PropTypes.object.isRequired,
}

export default Toolbar
