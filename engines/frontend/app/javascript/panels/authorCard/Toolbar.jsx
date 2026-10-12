import React, { useCallback, useContext } from 'react'
import { useDispatch } from 'react-redux'
import { Button } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBook } from '@fortawesome/free-solid-svg-icons/faBook'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import PinButton from 'components/PinButton'
import { saveAuthorPin } from 'store/authors/actions'
import UrlStoreContext from 'store/urlStore/Context'

const Toolbar = props => {
  const { authorFull, linkToAuthorPage = true } = props
  const { routes: { authorPagePath },
    routesReady } = useContext(UrlStoreContext)
  const dispatch = useDispatch()
  const savePin = useCallback(
    nextPinned => dispatch(saveAuthorPin(authorFull.id, nextPinned)),
    [authorFull.id, dispatch]
  )

  if (!routesReady) return null

  return (
    <div className='author-toolbar'>
      { linkToAuthorPage && authorFull.booksCount > 0 ? (
        <Button
          as={InternalLink}
          href={authorPagePath(authorFull.id)}
          title='See all books'
          variant='outline-info'
        >
          <FontAwesomeIcon icon={faBook} />

          { ` (${authorFull.booksCount})` }
        </Button>
      ) : null }

      <PinButton
        onChange={savePin}
        pinned={Boolean(authorFull.pinned)}
      />

      { (authorFull.externalLinks || []).map(link => (
        <ExternalTextLink
          href={link.url}
          key={link.url}
          label={link.label}
        />
      )) }
    </div>
  )
}

Toolbar.propTypes = {
  authorFull: PropTypes.object.isRequired,
  linkToAuthorPage: PropTypes.bool,
}

export default Toolbar
