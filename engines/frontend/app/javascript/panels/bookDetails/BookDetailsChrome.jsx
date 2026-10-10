import React from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircleXmark } from '@fortawesome/free-solid-svg-icons/faCircleXmark'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

export const bookDetailsClassName = (book, reducedHeight) => {
  const classes = ['panel--book-details', 'panel--widget']
  if (book.format === 'collection') classes.push('panel--book-details--collection')
  if (reducedHeight) classes.push('book-details-panel--compact')
  return classes.join(' ')
}

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

export const BookDetailsClose = ({ onClose }) => (
  <button
    aria-label='Clear selected included work'
    className='book-details-panel-close'
    onClick={onClose}
    type='button'
  >
    <FontAwesomeIcon icon={faCircleXmark} />
  </button>
)

BookDetailsClose.propTypes = {
  onClose: PropTypes.func.isRequired,
}
