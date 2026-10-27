import React from 'react'
import PropTypes from 'prop-types'

import BookToolbar from 'components/BookToolbar'
import BookDetailsCardLinks from 'panels/bookDetails/bookDetailsCard/BookDetailsCardLinks'
import BookDetailsCardPublicLists from 'panels/bookDetails/bookDetailsCard/BookDetailsCardPublicLists'
import BookDetailsCardTags from 'panels/bookDetails/bookDetailsCard/BookDetailsCardTags'

const BookDetailsCardSupplement = ({
  book,
  bookPagePath,
  links,
  listPagePath,
  showPublicLists,
  tags,
}) => (
  <div className='book-details-panel-supplement'>
    <div className='book-details-panel-toolbar'>
      <BookToolbar
        bookId={book.id}
        bookPageHref={bookPagePath(book.id)}
        pinned={Boolean(book.pinned)}
        read={Boolean(book.read)}
      />
    </div>

    { links.length > 0 ? <BookDetailsCardLinks links={links} /> : null }

    { showPublicLists && book.publicLists?.length > 0 ? (
      <BookDetailsCardPublicLists
        bookId={book.id}
        listPagePath={listPagePath}
        publicLists={book.publicLists}
      />
    ) : null }

    { tags.length > 0 ? <BookDetailsCardTags tags={tags} /> : null }
  </div>
)

BookDetailsCardSupplement.propTypes = {
  book: PropTypes.object.isRequired,
  bookPagePath: PropTypes.func.isRequired,
  links: PropTypes.arrayOf(PropTypes.object).isRequired,
  listPagePath: PropTypes.func.isRequired,
  showPublicLists: PropTypes.bool.isRequired,
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardSupplement
