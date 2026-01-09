import React, { useContext } from 'react'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBook } from '@fortawesome/free-solid-svg-icons'
import PropTypes from 'prop-types'

import UrlStoreContext from 'store/urlStore/Context'

const Toolbar = props => {
  const { tagIndexEntry } = props
  const { routes: { tagPagePath }, routesReady } = useContext(UrlStoreContext)

  if (!tagIndexEntry) return null
  if (!routesReady) return null

  return (
    <ButtonGroup className='toolbar'>
      { tagIndexEntry.bookConnectionsCount > 0 &&
      <Button
        href={tagPagePath(tagIndexEntry.id)}
        title='See all books'
        variant='outline-info'
      >
        <FontAwesomeIcon icon={faBook} />

        { ` (${tagIndexEntry.bookConnectionsCount})` }
      </Button>}
    </ButtonGroup>
  )
}

Toolbar.propTypes = {
  tagIndexEntry: PropTypes.object.isRequired,
}

export default Toolbar
