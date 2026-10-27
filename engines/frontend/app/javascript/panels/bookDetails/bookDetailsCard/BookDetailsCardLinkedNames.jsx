import React from 'react'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

const BookDetailsCardLinkedNames = ({ entries, buildHref }) => (
  <>
    { entries.map((entry, index) => (
      <React.Fragment key={entry.id}>
        { index > 0 && ', ' }

        <InternalLink
          href={buildHref(entry)}
          title={entry.name || entry.fullname}
        >
          { entry.name || entry.fullname }
        </InternalLink>
      </React.Fragment>
    )) }
  </>
)

BookDetailsCardLinkedNames.propTypes = {
  buildHref: PropTypes.func.isRequired,
  entries: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardLinkedNames
