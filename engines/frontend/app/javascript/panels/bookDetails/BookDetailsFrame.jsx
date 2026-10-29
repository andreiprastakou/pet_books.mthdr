import React from 'react'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

export const bookDetailsClassName = () => 'panel--book-details panel--widget'

export const BookDetailsHeader = ({ booksPagePath, header, title }) => header ? (
  <span className='book-details-panel-title'>
    { header }
  </span>
) : (
  <>
    <InternalLink href={booksPagePath()}>
      { 'Books' }
    </InternalLink>

    { '/' }

    <span
      className='book-details-panel-title'
      title={title}
    >
      { title }
    </span>
  </>
)

BookDetailsHeader.propTypes = {
  booksPagePath: PropTypes.func.isRequired,
  header: PropTypes.node,
  title: PropTypes.string.isRequired,
}
