import React, { useContext, useEffect } from 'react'
import { ButtonGroup, Card } from 'react-bootstrap'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import Book from 'components/Book'
import BookToolbar from 'components/BookToolbar'
import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import TagBadge from 'components/TagBadge'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import { selectCoverDesign } from 'store/coverDesigns/selectors'
import { fetchCurrentBookDetails } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import { selectSeriesRefsByIds } from 'store/series/selectors'
import { selectTagsRefsByIds } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { coverBackgroundStyle, coverPaletteForId } from 'utils/coverPalettes'

const renderAuthors = (authorRefs, bookId, authorPagePath) => (
  <>
    { authorRefs.map((authorRef, index) => (
      <React.Fragment key={authorRef.id}>
        { index > 0 && ', ' }

        <InternalLink
          href={authorPagePath(authorRef.id, { bookId })}
          title={authorRef.fullname}
        >
          { authorRef.fullname }
        </InternalLink>
      </React.Fragment>
    )) }
  </>
)

const renderSeries = (seriesRefs, bookId, seriesPagePath) => (
  <>
    { seriesRefs.map((seriesRef, index) => (
      <React.Fragment key={seriesRef.id}>
        { index > 0 && ', ' }

        <InternalLink
          href={seriesPagePath(seriesRef.id, { bookId })}
          title={seriesRef.name}
        >
          { seriesRef.name }
        </InternalLink>
      </React.Fragment>
    )) }
  </>
)

const comparePublicLists = (a, b) => {
  if (a.publicListYear !== b.publicListYear)
    return b.publicListYear - a.publicListYear

  return a.publicListTypeName.localeCompare(b.publicListTypeName)
}

const renderPublicLists = (publicLists, listPagePath, bookId) => (
  <div className='book-details-panel-public-lists'>
    { [...publicLists].sort(comparePublicLists).map(entry => (
      <div key={entry.publicListId}>
        { `${entry.publicListYear}: ` }

        <InternalLink
          href={listPagePath(entry.publicListTypeId, { bookId: bookId, listId: entry.publicListId })}
          title={entry.publicListTypeName}
        >
          { entry.publicListTypeName }
        </InternalLink>

        { ` - ${entry.bookRole}` }
      </div>
    )) }
  </div>
)

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

const BookBackCover = ({ bookId, coverImage }) => (
  <div
    className='b-cover-standard book-back-cover'
    data-cover-image={coverImage}
    style={coverImage === 'default' ? coverBackgroundStyle(coverPaletteForId(bookId)) : null}
  >
    { coverImage === 'default' ? <div className='b-cover-texture' /> : null }
  </div>
)

BookBackCover.propTypes = {
  bookId: PropTypes.number.isRequired,
  coverImage: PropTypes.string.isRequired,
}

const BookWithBackCover = ({ bookIndexEntry }) => {
  const coverDesign = useSelector(selectCoverDesign(bookIndexEntry.coverDesignId))

  return (
    <>
      { coverDesign ? (
        <BookBackCover
          bookId={bookIndexEntry.id}
          coverImage={coverDesign.coverImage}
        />
      ) : null }

      <Book bookIndexEntry={bookIndexEntry} />
    </>
  )
}

BookWithBackCover.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
}

const BookDetails = ({ header = null, showCover = true, showPublicLists = true }) => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry?.authorIds || []), shallowEqual)
  const seriesRefs = useSelector(selectSeriesRefsByIds(bookDetails.seriesIds || []), shallowEqual)
  const tags = useSelector(selectTagsRefsByIds(bookDetails.tagIds || []), shallowEqual)
  const { routes: { authorPagePath, booksPagePath, bookPagePath, listPagePath, seriesPagePath }, routesReady } = useContext(UrlStoreContext)
  useEffect(() => {
    if (bookIndexEntry && bookDetails.id !== bookIndexEntry.id)
      dispatch(fetchCurrentBookDetails())
  }, [bookIndexEntry?.id, bookDetails.id])

  const book = bookIndexEntry && bookDetails.id === bookIndexEntry.id
    ? bookDetails
    : null
  const links = book ? [
    ...(book.wikiUrl ? [{ name: 'wikipedia', url: book.wikiUrl }] : []),
    ...(book.genericLinks || []),
  ] : []

  if (!book || !routesReady) return null

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
          <div className='book-details-panel-main-info'>
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

            { book.formLabel ? (
              <div className='book-details-panel-form-label'>
                { book.formLabel }
              </div>
            ) : null }

            <div className='book-details-panel-authors'>
              { 'by ' }

              { renderAuthors(authorRefs, book.id, authorPagePath) }
            </div>

            { seriesRefs.length > 0 ? (
              <div className='book-details-panel-series'>
                { 'from series ' }

                { renderSeries(seriesRefs, book.id, seriesPagePath) }
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

          { links.length > 0 ? (
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
              ) : null }

          <div className='book-details-panel-toolbar'>
            <BookToolbar bookPageHref={bookPagePath(book.id)} />
          </div>

          { showPublicLists && book.publicLists?.length > 0 ?
            renderPublicLists(book.publicLists, listPagePath, book.id) : null }

          { tags.length > 0 ? (
            <div className='book-details-panel-tags'>
              { tags.map(tag => (
                <TagBadge
                  id={tag.id}
                  key={tag.id}
                  text={tag.name}
                />
                  )) }
            </div>
          ) : null }
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

BookDetailsHeader.propTypes = {
  booksPagePath: PropTypes.func.isRequired,
  header: PropTypes.node,
  title: PropTypes.string.isRequired,
}

BookDetails.propTypes = {
  header: PropTypes.node,
  showCover: PropTypes.bool,
  showPublicLists: PropTypes.bool,
}

export default BookDetails
