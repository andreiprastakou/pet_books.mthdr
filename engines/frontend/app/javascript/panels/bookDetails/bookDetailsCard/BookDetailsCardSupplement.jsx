import React from 'react'
import PropTypes from 'prop-types'

import BookToolbar from 'components/BookToolbar'
import BookDetailsCardIncludedWorks from 'panels/bookDetails/bookDetailsCard/BookDetailsCardIncludedWorks'
import BookDetailsCardLinks from 'panels/bookDetails/bookDetailsCard/BookDetailsCardLinks'
import BookDetailsCardPublicLists from 'panels/bookDetails/bookDetailsCard/BookDetailsCardPublicLists'
import BookDetailsCardTags from 'panels/bookDetails/bookDetailsCard/BookDetailsCardTags'

const BookDetailsCardSupplement = ({
  book,
  bookPagePath,
  includedWorkIds,
  links,
  listPagePath,
  showAuthorsInIncludedWorks,
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

    { includedWorkIds ? (
      <BookDetailsCardIncludedWorks
        bookPagePath={bookPagePath}
        showAuthors={showAuthorsInIncludedWorks}
        workIds={includedWorkIds}
      />
    ) : null }

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
  includedWorkIds: PropTypes.arrayOf(PropTypes.number),
  links: PropTypes.arrayOf(PropTypes.object).isRequired,
  listPagePath: PropTypes.func.isRequired,
  showAuthorsInIncludedWorks: PropTypes.bool.isRequired,
  showPublicLists: PropTypes.bool.isRequired,
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCardSupplement
