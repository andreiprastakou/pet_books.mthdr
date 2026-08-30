import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import classNames from 'classnames'

import { selectTagRef, selectCategory } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TagBadge = ({ text, id = null, renderPostfix = null, classes = '', onClick = null }) => {
  const label = `#${text}`
  const tagRef = useSelector(selectTagRef(id))
  const category = useSelector(selectCategory(tagRef?.categoryId))
  const { routes: { tagPagePath }, actions: { goto }, routesReady } = useContext(UrlStoreContext)
  const classnames = classNames(['tag-container', 'tag-badge', `tag-category-${category.name}`, classes])
  const clickHandler = useCallback(() => onClick ? onClick() : goto(tagPagePath(id)), [goto, tagPagePath])

  if (!tagRef || !category) return null
  if (!routesReady) return null

  return (
    <span
      className={classnames}
    >
      <a
        className='tag-name'
        href={tagPagePath(id)}
        onClick={clickHandler}
      >
        { label }
      </a>

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
