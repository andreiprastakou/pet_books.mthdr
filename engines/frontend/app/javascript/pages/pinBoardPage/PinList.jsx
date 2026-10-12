import React, { Children } from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

const PinList = ({ children, label }) => (
  <Card
    aria-label={label}
    className='panel--pin-list panel--widget'
    role='region'
  >
    <Card.Header className='panel--header'>
      <span>
        { label }
      </span>

      <span className='pin-board-count-badge'>
        { Children.count(children) }
      </span>
    </Card.Header>

    <Card.Body className='panel--body'>
      <div className='pin-board-entries'>
        { children }
      </div>
    </Card.Body>
  </Card>
)

const PinEntry = ({ children, href, title }) => (
  <div className='pin-board-entry'>
    <InternalLink
      href={href}
      title={title}
    >
      { children }
    </InternalLink>
  </div>
)

PinList.propTypes = {
  children: PropTypes.node,
  label: PropTypes.string.isRequired,
}

PinEntry.propTypes = {
  children: PropTypes.node.isRequired,
  href: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
}

export { PinEntry }
export default PinList
