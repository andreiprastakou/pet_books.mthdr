import React from 'react'
import { Button } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import PropTypes from 'prop-types'

const RESOURCE_LINK_TEXT = {
  wikipedia: 'Wikipedia',
  goodreads: 'Goodreads',
  official: 'Official link',
}

const ExternalTextLink = ({ resource, href, className = 'external-link' }) => (
  <Button
    className={className}
    href={href}
    rel='noreferrer'
    target='_blank'
    variant='outline-secondary'
  >
    { RESOURCE_LINK_TEXT[resource] || resource }

    <FontAwesomeIcon
      className='external-link-icon'
      icon={faLink}
    />
  </Button>
)

ExternalTextLink.propTypes = {
  className: PropTypes.string,
  href: PropTypes.string.isRequired,
  resource: PropTypes.string.isRequired,
}

export default ExternalTextLink
