import React from 'react'
import PropTypes from 'prop-types'

import InternalLink from 'components/InternalLink'

const comparePublicLists = (a, b) => {
  if (a.publicListYear !== b.publicListYear)
    return b.publicListYear - a.publicListYear

  return a.publicListTypeName.localeCompare(b.publicListTypeName)
}

const BookDetailsCardPublicLists = ({ bookId, listPagePath, publicLists }) => (
  <div className='book-details-panel-public-lists'>
    { [...publicLists].sort(comparePublicLists).map(entry => (
      <div key={entry.publicListId}>
        { `${entry.publicListYear}: ` }

        <InternalLink
          href={listPagePath(entry.publicListTypeId, { bookId, listId: entry.publicListId })}
          title={entry.publicListTypeName}
        >
          { entry.publicListTypeName }
        </InternalLink>

        { ` - ${entry.bookRole}` }
      </div>
    )) }
  </div>
)

BookDetailsCardPublicLists.propTypes = {
  bookId: PropTypes.number.isRequired,
  listPagePath: PropTypes.func.isRequired,
  publicLists: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardPublicLists
