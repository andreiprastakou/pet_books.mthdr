import React, { useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useDispatch } from 'react-redux'
import { HotKeys } from 'react-hotkeys'

import { shiftSelection } from 'widgets/booksListLinear/actions'

const keyMap = {
  DOWN: 'Down',
  UP: 'Up',
  LEFT: 'Left',
  RIGHT: 'Right',
}

const HotKeysWrap = ({ children }) => {
  const dispatch = useDispatch()
  const ref = useRef(null)

  useEffect(() => ref.current.focus(), [])

  const hotKeysHandlers = () => ({
    DOWN: () => dispatch(shiftSelection(+4)),
    UP: () => dispatch(shiftSelection(-4)),
    RIGHT: () => {
      dispatch(shiftSelection(+1))
    },
    LEFT: () => {
      dispatch(shiftSelection(-1))
    },
  })

  return (
    <HotKeys
      handlers={hotKeysHandlers()}
      keyMap={keyMap}
    >
      <div
        ref={ref}
        tabIndex="-1"
      >
        { children }
      </div>
    </HotKeys>
  )
}

HotKeysWrap.propTypes = {
  children: PropTypes.node.isRequired,
}

export default HotKeysWrap
