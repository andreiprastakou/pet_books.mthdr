import React from 'react'
import { Button } from 'react-bootstrap'
import PropTypes from 'prop-types'

const ExternalTextLink = ({ text, href }) => (
  <Button
    href={href}
    rel='noreferrer'
    target='_blank'
    variant='outline-secondary'
  >
    { text }
  </Button>
)

ExternalTextLink.propTypes = {
  href: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
}

export default ExternalTextLink
