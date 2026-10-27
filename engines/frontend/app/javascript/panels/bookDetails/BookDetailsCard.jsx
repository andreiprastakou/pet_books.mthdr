import React, { useCallback } from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import BookToolbar from 'components/BookToolbar'
import useScrollToTop from 'hooks/useScrollToTop'
import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import TagBadge from 'components/TagBadge'
import {
  BookDetailsClose,
  BookDetailsHeader,
  bookDetailsClassName,
} from 'panels/bookDetails/BookDetailsFrame'
import BookWithBackCover from 'panels/bookDetails/BookWithBackCover'
import { coverSizeClass, coverSizeType } from 'utils/coverSizes'

const LinkedNames = ({ entries, buildHref }) => (
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

LinkedNames.propTypes = {
  buildHref: PropTypes.func.isRequired,
  entries: PropTypes.arrayOf(PropTypes.object).isRequired,
}

const comparePublicLists = (a, b) => {
  if (a.publicListYear !== b.publicListYear)
    return b.publicListYear - a.publicListYear

  return a.publicListTypeName.localeCompare(b.publicListTypeName)
}

const BookPublicLists = ({ bookId, listPagePath, publicLists }) => (
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

BookPublicLists.propTypes = {
  bookId: PropTypes.number.isRequired,
  listPagePath: PropTypes.func.isRequired,
  publicLists: PropTypes.arrayOf(PropTypes.object).isRequired,
}

const BookDetailsHeading = ({ book, booksPagePath }) => (
  <div className='book-details-panel-heading'>
    <h2>
      { book.title }
    </h2>

    <span>
      <InternalLink href={booksPagePath({ bookId: book.id })}>
        { book.yearPublished }
      </InternalLink>
    </span>
  </div>
)

BookDetailsHeading.propTypes = {
  book: PropTypes.object.isRequired,
  booksPagePath: PropTypes.func.isRequired,
}

const BookDetailsAnnotation = ({ book }) => {
  if (!book.summary) return null

  return (
    <div className='book-details-panel-annotation'>
      <p>
        { book.summary }
      </p>

      { book.summarySource ? (
        <div className='description-source'>
          { `(source: ${book.summarySource})` }
        </div>
      ) : null }
    </div>
  )
}

BookDetailsAnnotation.propTypes = {
  book: PropTypes.object.isRequired,
}

const BookDetailsMainInfo = ({
  authorPagePath,
  authorRefs,
  book,
  booksPagePath,
  seriesPagePath,
  seriesRefs,
  showSummary,
}) => {
  const authorHref = useCallback(
    author => authorPagePath(author.id, { bookId: book.id }),
    [authorPagePath, book.id]
  )
  const seriesHref = useCallback(
    series => seriesPagePath(series.id, { bookId: book.id }),
    [book.id, seriesPagePath]
  )

  return (
    <div className='book-details-panel-main-info'>
      <BookDetailsHeading
        book={book}
        booksPagePath={booksPagePath}
      />

      { book.formLabel ? (
        <div className='book-details-panel-form-label'>
          { book.formLabel }
        </div>
      ) : null }

      <div className='book-details-panel-authors'>
        { 'by ' }

        <LinkedNames
          buildHref={authorHref}
          entries={authorRefs}
        />
      </div>

      { seriesRefs.length > 0 ? (
        <div className='book-details-panel-series'>
          { 'from series ' }

          <LinkedNames
            buildHref={seriesHref}
            entries={seriesRefs}
          />
        </div>
      ) : null }

      { showSummary ? <BookDetailsAnnotation book={book} /> : null }
    </div>
  )
}

BookDetailsMainInfo.propTypes = {
  authorPagePath: PropTypes.func.isRequired,
  authorRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  book: PropTypes.object.isRequired,
  booksPagePath: PropTypes.func.isRequired,
  seriesPagePath: PropTypes.func.isRequired,
  seriesRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  showSummary: PropTypes.bool.isRequired,
}

const BookDetailsLinks = ({ links }) => (
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

BookDetailsLinks.propTypes = {
  links: PropTypes.arrayOf(PropTypes.object).isRequired,
}

const BookDetailsTags = ({ tags }) => (
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

BookDetailsTags.propTypes = {
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

const bookDetailsLinks = book => book.externalLinks || []

const BookDetailsSupplement = ({
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

    { links.length > 0 ? <BookDetailsLinks links={links} /> : null }

    { showPublicLists && book.publicLists?.length > 0 ? (
      <BookPublicLists
        bookId={book.id}
        listPagePath={listPagePath}
        publicLists={book.publicLists}
      />
    ) : null }

    { tags.length > 0 ? <BookDetailsTags tags={tags} /> : null }
  </div>
)

BookDetailsSupplement.propTypes = {
  book: PropTypes.object.isRequired,
  bookPagePath: PropTypes.func.isRequired,
  links: PropTypes.arrayOf(PropTypes.object).isRequired,
  listPagePath: PropTypes.func.isRequired,
  showPublicLists: PropTypes.bool.isRequired,
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

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
    <BookDetailsSupplement
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
          <BookDetailsMainInfo
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

        { summaryBelow ? <BookDetailsAnnotation book={book} /> : null }

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
