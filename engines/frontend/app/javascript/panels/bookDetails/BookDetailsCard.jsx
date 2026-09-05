import React, { useCallback } from 'react'
import { ButtonGroup, Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import BookToolbar from 'components/BookToolbar'
import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import TagBadge from 'components/TagBadge'
import BookWithBackCover from 'panels/bookDetails/BookWithBackCover'

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

const BookDetailsHeader = ({ booksPagePath, header, title }) => header || (
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

const BookDetailsMainInfo = ({
  authorPagePath,
  authorRefs,
  book,
  booksPagePath,
  seriesPagePath,
  seriesRefs,
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

      { book.summary ? (
        <div className='book-details-panel-annotation'>
          <p>
            { book.summary }
          </p>
        </div>
      ) : null }
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
}

const BookDetailsLinks = ({ links }) => (
  <div className='book-details-panel-links'>
    <ButtonGroup>
      { links.map(link => (
        <ExternalTextLink
          href={link.url}
          key={link.url}
          resource={link.name}
        />
      )) }
    </ButtonGroup>
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

const bookDetailsLinks = book => [
  ...(book.wikiUrl ? [{ name: 'wikipedia', url: book.wikiUrl }] : []),
  ...(book.genericLinks || []),
]

const BookDetailsCard = ({
  authorPagePath,
  authorRefs,
  book,
  bookIndexEntry,
  bookPagePath,
  booksPagePath,
  header,
  listPagePath,
  seriesPagePath,
  seriesRefs,
  showCover,
  showPublicLists,
  tags,
}) => {
  const links = bookDetailsLinks(book)

  return (
    <Card className='panel--book-details panel--widget'>
      <Card.Header className='panel--header'>
        <BookDetailsHeader
          booksPagePath={booksPagePath}
          header={header}
          title={book.title}
        />
      </Card.Header>

      <Card.Body className='panel--body'>
        <div className='book-details-panel-content'>
          <BookDetailsMainInfo
            authorPagePath={authorPagePath}
            authorRefs={authorRefs}
            book={book}
            booksPagePath={booksPagePath}
            seriesPagePath={seriesPagePath}
            seriesRefs={seriesRefs}
          />

          { links.length > 0 ? <BookDetailsLinks links={links} /> : null }

          <div className='book-details-panel-toolbar'>
            <BookToolbar bookPageHref={bookPagePath(book.id)} />
          </div>

          { showPublicLists && book.publicLists?.length > 0 ? (
            <BookPublicLists
              bookId={book.id}
              listPagePath={listPagePath}
              publicLists={book.publicLists}
            />
          ) : null }

          { tags.length > 0 ? <BookDetailsTags tags={tags} /> : null }
        </div>

        { showCover ? (
          <div className='book-details-panel-cover'>
            <BookWithBackCover bookIndexEntry={bookIndexEntry} />
          </div>
        ) : null }
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
  header: PropTypes.node,
  listPagePath: PropTypes.func.isRequired,
  seriesPagePath: PropTypes.func.isRequired,
  seriesRefs: PropTypes.arrayOf(PropTypes.object).isRequired,
  showCover: PropTypes.bool.isRequired,
  showPublicLists: PropTypes.bool.isRequired,
  tags: PropTypes.arrayOf(PropTypes.object).isRequired,
}

export default BookDetailsCard
