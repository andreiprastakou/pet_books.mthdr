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

const HotKeysWrap = (props) => {
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
    <HotKeys keyMap={ keyMap } handlers={ hotKeysHandlers() }>
      <div tabIndex="-1" ref={ ref }>
        { props.children }
      </div>
    </HotKeys>
  )
}

export default HotKeysWrap
