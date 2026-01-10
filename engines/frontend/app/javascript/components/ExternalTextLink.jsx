import React from 'react'
import PropTypes from 'prop-types'

const ExternalTextLink = ({ text, href }) => (
  <a
    href={href}
    rel='noreferrer'
    target='_blank'
  >
    { text }
  </a>
)

ExternalTextLink.propTypes = {
  href: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
}

export default ExternalTextLink
