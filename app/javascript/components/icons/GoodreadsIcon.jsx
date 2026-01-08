import React from 'react'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGoodreadsG } from '@fortawesome/free-brands-svg-icons'

const GoodreadsIcon = ({ url }) => {
  if (!url)  return null

  return (
    <a
      className='icon-goodreads'
      href={url}
      rel="noreferrer"
      target='_blank'
    >
      <FontAwesomeIcon icon={faGoodreadsG} />
    </a>
  )
}

GoodreadsIcon.propTypes = {
  url: PropTypes.string
}

GoodreadsIcon.defaultProps = {
  url: null,
}

export default GoodreadsIcon
