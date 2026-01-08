import React, { useCallback } from 'react'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBook } from '@fortawesome/free-solid-svg-icons'

const BookIcon = ({ onClick }) => {
  const handleClick = useCallback(e => {
    e.preventDefault()
    onClick(e)
  }, [onClick])
  return (
    <a
      className='icon-edit'
      href='#'
      onClick={handleClick}
    >
      <FontAwesomeIcon icon={faBook} />
    </a>
  )
}

BookIcon.propTypes = {
  onClick: PropTypes.func.isRequired
}

export default BookIcon
