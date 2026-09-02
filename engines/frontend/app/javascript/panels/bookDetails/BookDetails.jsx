import React, { useContext, useEffect } from 'react'
import { ButtonGroup, Card } from 'react-bootstrap'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import Book from 'components/Book'
import BookToolbar from 'components/BookToolbar'
import ExternalTextLink from 'components/ExternalTextLink'
import TagBadge from 'components/TagBadge'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import { fetchCurrentBookDetails } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import { selectTagsRefsByIds } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const renderAuthors = (authorRefs, bookId, authorPagePath) => (
  <>
    { authorRefs.map((authorRef, index) => (
      <React.Fragment key={authorRef.id}>
        { index > 0 && ', ' }

        <a
          className='internal-link'
          href={authorPagePath(authorRef.id, { bookId })}
          title={authorRef.fullname}
        >
          { authorRef.fullname }
        </a>
      </React.Fragment>
    )) }
  </>
)

const BookDetailsHeader = ({ header, title }) => header || (
  <>
    <a
      className='internal-link'
      href='/books'
    >
      { 'Books' }
    </a>

    { '/' }

    <span
      className='book-details-panel-title'
      title={title}
    >
      { title }
    </span>
  </>
)

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
              <a
                className='internal-link'
                href={booksPagePath({ bookId: book.id })}
              >
                { book.yearPublished }
              </a>
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
                    text={link.name}
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

        { showCover && bookIndexEntry.coverDesignId !== 'standard' ? (
          <div className='book-details-panel-cover'>
            <Book bookIndexEntry={bookIndexEntry} />
          </div>
        ) : null }
      </Card.Body>
    </Card>
  )
}

BookDetailsHeader.propTypes = {
  header: PropTypes.node,
  title: PropTypes.string.isRequired,
}

BookDetails.propTypes = {
  header: PropTypes.node,
  showCover: PropTypes.bool,
}

export default BookDetails
