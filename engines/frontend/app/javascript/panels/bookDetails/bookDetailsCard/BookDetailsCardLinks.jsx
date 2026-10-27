import React from 'react'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'

const BookDetailsCardLinks = ({ links }) => (
  <div className='book-details-panel-links'>
    { links.map(link => (
      <ExternalTextLink
        href={link.url}
        key={link.url}
        label={link.label}
      />
    )) }
  </div>
)

BookDetailsCardLinks.propTypes = {
  links: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardLinks
