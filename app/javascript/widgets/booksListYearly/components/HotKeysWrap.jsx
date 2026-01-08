import React, { useCallback, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useDispatch } from 'react-redux'
import { HotKeys } from 'react-hotkeys'

import {
  jumpToFirstYear,
  jumpToLastYear,
  setBookShiftDirectionHorizontal,
  shiftSelection,
  shiftYear,
} from 'widgets/booksListYearly/actions'

const keyMap = {
  DOWN: 'Down',
  PAGE_DOWN: 'PageDown',
  END: 'End',
  UP: 'Up',
  PAGE_UP: 'PageUp',
  START: 'Home',
  LEFT: 'Left',
  RIGHT: 'Right',
}

const HotKeysWrap = ({ children }) => {
  const dispatch = useDispatch()
  const ref = useRef(null)

  useEffect(() => ref.current.focus(), [])

  const hotKeysHandlers = () => ({
    DOWN: () => dispatch(shiftYear(-1)),
    PAGE_DOWN: () => dispatch(shiftYear(-2)),
    END: () => dispatch(jumpToFirstYear()),
    UP: () => dispatch(shiftYear(+1)),
    PAGE_UP: () => dispatch(shiftYear(+2)),
    START: () => dispatch(jumpToLastYear()),

    RIGHT: () => {
      dispatch(setBookShiftDirectionHorizontal('right'))
      dispatch(shiftSelection(+1))
    },
    LEFT: () => {
      dispatch(setBookShiftDirectionHorizontal('left'))
      dispatch(shiftSelection(-1))
    },
  })

  const handleWheel = useCallback(({ deltaY }) => {
    const speed = Math.abs(deltaY) / 150
    if (deltaY > 0)
      dispatch(shiftYear(-speed))
    else if (deltaY < 0)
      dispatch(shiftYear(Number(speed)))
  }, [])

  return (
    <HotKeys
      handlers={hotKeysHandlers()}
      keyMap={keyMap}
    >
      <div
        onWheel={handleWheel}
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
