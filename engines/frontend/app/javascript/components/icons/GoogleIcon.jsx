import { compact } from 'lodash'
import React from 'react'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGoogle } from '@fortawesome/free-brands-svg-icons'

const EMPTY_OBJECT = {}

const GoogleIcon = ({ queryParts, optionalParams = EMPTY_OBJECT }) => {
  if (compact(queryParts).length !== queryParts.length)  return null

  const params = new URLSearchParams()
  params.append('q', queryParts.join(' '))
  Object.keys(optionalParams).forEach(key => params.append(key, optionalParams[key]))
  const url = `http://google.com/search?${params.toString()}`

  return (
    <a
      className='icon-google'
      href={url}
      rel="noreferrer"
      target='_blank'
    >
      <FontAwesomeIcon icon={faGoogle} />
    </a>
  )
}

GoogleIcon.propTypes = {
  optionalParams: PropTypes.object,
  queryParts: PropTypes.array.isRequired
}

export default GoogleIcon
