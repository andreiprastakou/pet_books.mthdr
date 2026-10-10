import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectPageIsLoading } from 'store/metadata/selectors'

// The frame is the only box that is sized to the viewport. Columns share its
// width (1, 2, or 3 thirds). Slots in a column share its height. A panel
// fills its slot and scrolls inside; it does not set a viewport height.
const PageFrame = ({ children, className = '' }) => {
  const pageIsLoading = useSelector(selectPageIsLoading())
  if (pageIsLoading) return 'Wait...'

  const classes = ['page-frame', className].filter(Boolean).join(' ')

  return (
    <div className={classes}>
      { children }
    </div>
  )
}

const Column = ({ children, span = 1 }) => (
  <div className={`page-column page-column-span-${span}`}>
    { children }
  </div>
)

// grow is a share of the column, not a pixel height. 1 and 1 split evenly.
// 0 sizes to content between minHeight and maxHeight, then scrolls; the
// following slot takes the height that remains.
// An empty slot (a child that rendered nothing) drops out via :empty.
const Slot = ({ children, grow = 1, maxHeight = null, minHeight = null }) => {
  const style = {}
  if (grow > 0 && grow !== 1) style.flexGrow = grow
  if (minHeight) style['--slot-min-height'] = minHeight
  if (maxHeight) style['--slot-max-height'] = maxHeight

  return (
    <div
      className='panel-slot'
      data-grow={grow}
      style={Object.keys(style).length ? style : undefined}
    >
      { children }
    </div>
  )
}

PageFrame.propTypes = {
  children: PropTypes.node.isRequired,
  className: PropTypes.string,
}

Column.propTypes = {
  children: PropTypes.node.isRequired,
  span: PropTypes.oneOf([1, 2, 3]),
}

Slot.propTypes = {
  children: PropTypes.node,
  grow: PropTypes.number,
  maxHeight: PropTypes.string,
  minHeight: PropTypes.string,
}

export { Column, Slot }
export default PageFrame
