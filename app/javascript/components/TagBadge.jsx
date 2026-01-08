import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Badge } from 'react-bootstrap'
import PropTypes from 'prop-types'
import classNames from 'classnames'

import { selectTagRef, selectCategory } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TagBadge = ({ text, id = null, renderPostfix = null, classes = '', variant = 'light', onClick = null }) => {
  const label = `#${text}`
  const tagRef = useSelector(selectTagRef(id))
  const category = useSelector(selectCategory(tagRef?.categoryId))
  const { routes: { tagPagePath }, actions: { goto }, routesReady } = useContext(UrlStoreContext)

  if (!tagRef || !category) return null
  if (!routesReady) return null

  const classnames = classNames(['tag-container', `tag-category-${category.name}`, classes])
  const clickHandler = useCallback(() => onClick ? onClick() : goto(tagPagePath(id)), [goto, tagPagePath])

  return (
    <Badge
      className={classnames}
      pill
      variant={variant}
    >
      <a
        className='tag-name'
        href={tagPagePath(id)}
        onClick={clickHandler}
      >
        { label }
      </a>

      { renderPostfix ? renderPostfix() : null }
    </Badge>
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
  variant: PropTypes.string,
}

export default TagBadge
