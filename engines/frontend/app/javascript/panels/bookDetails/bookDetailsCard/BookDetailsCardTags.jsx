import React from 'react'
import PropTypes from 'prop-types'

import TagBadge from 'components/TagBadge'

const BookDetailsCardTags = ({ tags }) => (
  <div className='book-details-panel-tags'>
    { tags.map(tag => (
      <TagBadge
        id={tag.id}
        key={tag.id}
        text={tag.name}
      />
    )) }
  </div>
)

BookDetailsCardTags.propTypes = {
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardTags
