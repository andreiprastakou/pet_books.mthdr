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

const BookDetails = ({ header = null, showCover = true }) => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry?.authorIds || []), shallowEqual)
  const tags = useSelector(selectTagsRefsByIds(bookDetails.tagIds || []), shallowEqual)
  const { routes: { authorPagePath, booksPagePath, bookPagePath }, routesReady } = useContext(UrlStoreContext)
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

          <div className='book-details-panel-authors'>
            { 'by ' }

            { renderAuthors(authorRefs, book.id, authorPagePath) }
          </div>

          <div className='book-details-panel-annotation'>
            <p>
              { book.summary || '<no information>' }
            </p>
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
}

export default BookDetails
