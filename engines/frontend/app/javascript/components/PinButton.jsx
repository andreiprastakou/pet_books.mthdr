import React, { useCallback, useEffect, useRef, useState } from 'react'
import { useDispatch } from 'react-redux'
import { Button } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import PropTypes from 'prop-types'
import { faCircleDot } from '@fortawesome/free-solid-svg-icons/faCircleDot'
import { faThumbtack } from '@fortawesome/free-solid-svg-icons/faThumbtack'
import { faThumbtackSlash } from '@fortawesome/free-solid-svg-icons/faThumbtackSlash'

import { addErrorMessage } from 'store/notifications/actions'

const PinButton = ({ onChange, pinned: savedPinned }) => {
  const dispatch = useDispatch()
  const [pinned, setPinned] = useState(savedPinned)
  const [hovered, setHovered] = useState(false)
  const pending = useRef(false)
  const title = pinned && hovered ? 'Unpin' : 'Pin'
  let icon = faThumbtack
  if (pinned && hovered) icon = faThumbtackSlash
  else if (pinned && !hovered) icon = faCircleDot

  useEffect(() => {
    setPinned(savedPinned)
  }, [savedPinned])

  const handleMouseEnter = useCallback(() => setHovered(true), [])
  const handleMouseLeave = useCallback(() => setHovered(false), [])
  const handleClick = useCallback(() => {
    if (pending.current) return

    const nextPinned = !pinned
    pending.current = true
    setPinned(nextPinned)
    onChange(nextPinned)
      .catch(() => {
        setPinned(savedPinned)
        dispatch(addErrorMessage('Could not update pin. Please try again.'))
      })
      .finally(() => {
        pending.current = false
      })
  }, [dispatch, onChange, pinned, savedPinned])

  return (
    <Button
      aria-label={title}
      aria-pressed={pinned}
      onClick={handleClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      title={title}
      type='button'
      variant='outline-warning'
    >
      <FontAwesomeIcon
        icon={icon}
        transform='shrink-2'
      />
    </Button>
  )
}

PinButton.propTypes = {
  onChange: PropTypes.func.isRequired,
  pinned: PropTypes.bool.isRequired,
}

export default PinButton
