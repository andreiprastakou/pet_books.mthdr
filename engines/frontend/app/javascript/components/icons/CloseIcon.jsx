import React, { useCallback } from 'react'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faTimesCircle } from '@fortawesome/free-solid-svg-icons'

const CloseIcon = ({ onClick }) => {
  const handleClick = useCallback(e => {
    e.preventDefault()
    onClick(e)
  }, [onClick])
  return (
    <a
      className='icon-close'
      href='#'
      onClick={handleClick}
    >
      <FontAwesomeIcon icon={faTimesCircle} />
    </a>
  )
}

CloseIcon.propTypes = {
  onClick: PropTypes.func.isRequired
}
export default CloseIcon
