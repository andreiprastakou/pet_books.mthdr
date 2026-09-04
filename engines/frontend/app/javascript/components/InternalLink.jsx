import React, { forwardRef, useCallback, useContext } from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'

import UrlStoreContext from 'store/urlStore/Context'

const isModifiedClick = event => (
  event.metaKey || event.altKey || event.ctrlKey || event.shiftKey
)

const InternalLink = forwardRef(({
  as: Component = 'a',
  children,
  className,
  href,
  onClick,
  target,
  ...rest
}, ref) => {
  const { actions: { goto } } = useContext(UrlStoreContext)

  const handleClick = useCallback(event => {
    if (onClick) onClick(event)
    if (event.defaultPrevented) return
    if (event.button !== 0) return
    if (isModifiedClick(event)) return
    if (target && target !== '_self') return

    event.preventDefault()
    goto(href)
  }, [goto, href, onClick, target])

  return (
    <Component
      // Bootstrap `as={InternalLink}` forwards dropdown/nav/button props.
      {...rest} // eslint-disable-line react/jsx-props-no-spreading
      className={classNames('internal-link', className)}
      href={href}
      onClick={handleClick}
      ref={ref}
      target={target}
    >
      { children }
    </Component>
  )
})

InternalLink.displayName = 'InternalLink'

InternalLink.propTypes = {
  as: PropTypes.elementType,
  children: PropTypes.node,
  className: PropTypes.string,
  href: PropTypes.string.isRequired,
  onClick: PropTypes.func,
  target: PropTypes.string,
}

export default InternalLink
