import React from 'react'
import { Button } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import PropTypes from 'prop-types'

const ExternalTextLink = ({ text, href, className = 'external-link' }) => (
  <Button
    className={className}
    href={href}
    rel='noreferrer'
    target='_blank'
    variant='outline-secondary'
  >
    { text }

    <FontAwesomeIcon
      className='external-link-icon'
      icon={faLink}
    />
  </Button>
)

ExternalTextLink.propTypes = {
  className: PropTypes.string,
  href: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
}

export default ExternalTextLink
