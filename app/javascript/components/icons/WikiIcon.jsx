import React from 'react'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faWikipediaW } from '@fortawesome/free-brands-svg-icons'

const WikiIcon = ({ url }) => {
  if (!url)  return null

  return (
    <a
      className='icon-wiki'
      href={url}
      rel="noreferrer"
      target='_blank'
    >
      <FontAwesomeIcon icon={faWikipediaW} />
    </a>
  )
}

WikiIcon.propTypes = {
  url: PropTypes.string
}

WikiIcon.defaultProps = {
  url: null,
}

export default WikiIcon
