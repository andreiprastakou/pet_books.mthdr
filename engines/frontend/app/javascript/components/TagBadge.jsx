import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import classNames from 'classnames'

import InternalLink from 'components/InternalLink'
import { selectTagRef } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TagBadge = ({ text, id = null, renderPostfix = null, classes = '', onClick = null }) => {
  const label = `#${text}`
  const tagRef = useSelector(selectTagRef(id))
  const { routes: { tagPagePath }, routesReady } = useContext(UrlStoreContext)

  const handleClick = useCallback(event => {
    if (!onClick) return
    event.preventDefault()
    onClick()
  }, [onClick])

  if (!tagRef) return null
  if (!routesReady) return null

  const classnames = classNames(['tag-container', 'tag-badge', classes])

  return (
    <span
      className={classnames}
    >
      <InternalLink
        className='tag-name'
        href={tagPagePath(id)}
        onClick={handleClick}
      >
        { label }
      </InternalLink>

      { renderPostfix ? renderPostfix() : null }
    </span>
  )
}

TagBadge.propTypes = {
  classes: PropTypes.string,
  id: PropTypes.number,
  onClick: PropTypes.func,
  renderPostfix: PropTypes.func,
  text: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ]).isRequired,
}

export default TagBadge
