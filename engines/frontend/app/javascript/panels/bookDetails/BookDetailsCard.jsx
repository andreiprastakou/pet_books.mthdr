import React from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import useScrollToTop from 'hooks/useScrollToTop'
import {
  BookDetailsClose,
  BookDetailsHeader,
  bookDetailsClassName,
} from 'panels/bookDetails/BookDetailsFrame'
import BookWithBackCover from 'panels/bookDetails/BookWithBackCover'
import BookDetailsCardAnnotation from 'panels/bookDetails/bookDetailsCard/BookDetailsCardAnnotation'
import BookDetailsCardMainInfo from 'panels/bookDetails/bookDetailsCard/BookDetailsCardMainInfo'
import BookDetailsCardSupplement from 'panels/bookDetails/bookDetailsCard/BookDetailsCardSupplement'
import { coverSizeClass, coverSizeType } from 'utils/coverSizes'

const bookDetailsLinks = book => book.externalLinks || []

const BookDetailsCard = ({
  authorPagePath,
  authorRefs,
  book,
  bookIndexEntry,
  bookPagePath,
  booksPagePath,
  compact,
  coverSize,
  header,
  listPagePath,
  onClose,
  reducedHeight,
  seriesPagePath,
  seriesRefs,
  showCover,
  showPublicLists,
  tags,
}) => {
  const links = bookDetailsLinks(book)
  const bodyRef = useScrollToTop(book.id)
  const summaryBelow = compact
  const supplement = (
    <BookDetailsCardSupplement
      book={book}
      bookPagePath={bookPagePath}
      links={links}
      listPagePath={listPagePath}
      showPublicLists={showPublicLists}
      tags={tags}
    />
  )

  return (
    <Card className={bookDetailsClassName(book, reducedHeight)}>
      <Card.Header className='panel--header'>
        <BookDetailsHeader
          booksPagePath={booksPagePath}
          header={header}
          title={book.title}
        />

        { onClose ? <BookDetailsClose onClose={onClose} /> : null }
      </Card.Header>

      <Card.Body
        className='panel--body'
        ref={bodyRef}
      >
        <div className='book-details-panel-content'>
          <BookDetailsCardMainInfo
            authorPagePath={authorPagePath}
            authorRefs={authorRefs}
            book={book}
            booksPagePath={booksPagePath}
            seriesPagePath={seriesPagePath}
            seriesRefs={seriesRefs}
            showSummary={!summaryBelow}
          />

          { summaryBelow ? null : supplement }
        </div>

        { showCover ? (
          <div className={`book-details-panel-cover ${coverSizeClass(coverSize)}`}>
            <BookWithBackCover
              bookIndexEntry={bookIndexEntry}
              size={coverSize}
            />
          </div>
        ) : null }

        { summaryBelow ? <BookDetailsCardAnnotation book={book} /> : null }

        { summaryBelow ? supplement : null }
      </Card.Body>
    </Card>
  )
}

BookDetailsCard.propTypes = {
  authorPagePath: PropTypes.func.isRequired,
  authorRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  book: PropTypes.object.isRequired,
  bookIndexEntry: PropTypes.object.isRequired,
  bookPagePath: PropTypes.func.isRequired,
  booksPagePath: PropTypes.func.isRequired,
  compact: PropTypes.bool.isRequired,
  coverSize: coverSizeType.isRequired,
  header: PropTypes.node,
  listPagePath: PropTypes.func.isRequired,
  onClose: PropTypes.func,
  reducedHeight: PropTypes.bool.isRequired,
  seriesPagePath: PropTypes.func.isRequired,
  seriesRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  showCover: PropTypes.bool.isRequired,
  showPublicLists: PropTypes.bool.isRequired,
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCard
