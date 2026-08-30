import React, { useContext, useEffect } from 'react'
import { Button, ButtonGroup, Card } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'

import Book from 'components/Book'
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
          href={authorPagePath(authorRef.id, { bookId })}
          title={authorRef.fullname}
        >
          { authorRef.fullname }
        </a>
      </React.Fragment>
    )) }
  </>
)

const SelectedBook = () => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry?.authorIds || []))
  const tags = useSelector(selectTagsRefsByIds(bookDetails.tagIds || []))
  const { routes: { authorPagePath }, routesReady } = useContext(UrlStoreContext)

  useEffect(() => {
    if (bookIndexEntry && bookDetails.id !== bookIndexEntry.id)
      dispatch(fetchCurrentBookDetails())
  }, [bookIndexEntry?.id, bookDetails.id])

  const book = bookIndexEntry && bookDetails.id === bookIndexEntry.id
    ? bookDetails
    : null
  const links = book ? [
    ...(book.wikiUrl ? [{ name: 'Wikipedia', url: book.wikiUrl }] : []),
    ...(book.genericLinks || []),
  ] : []

  if (!book || !routesReady) return null

  return (
    <Card className='selected-book sidebar-card-widget'>
      <Card.Header className='widget-title selected-book-header'>
        { 'Selected Work' }
      </Card.Header>

      <Card.Body className='selected-book-body'>
        <div className='selected-book-details'>
          <div className='selected-book-heading'>
            <h2>
              { book.title }
            </h2>

            <span>
              { book.yearPublished }
            </span>
          </div>

          <div className='selected-book-authors'>
            { 'by ' }

            { renderAuthors(authorRefs, book.id, authorPagePath) }
          </div>

          <div className='selected-book-annotation'>
            <p>
              { book.summary || '<no information>' }
            </p>
          </div>

          <div className='selected-book-tags'>
            { tags.map(tag => (
              <TagBadge
                id={tag.id}
                key={tag.id}
                text={tag.name}
              />
                )) }
          </div>

          { links.length > 0 ? (
            <div className='selected-book-links'>
              <ButtonGroup>
                { links.map(link => (
                  <Button
                    href={link.url}
                    key={link.url}
                    target='_blank'
                    variant='outline-secondary'
                  >
                    { link.name }
                  </Button>
                    )) }
              </ButtonGroup>
            </div>
              ) : null }
        </div>

        { bookIndexEntry.coverDesignId === 'standard' ? null : (
          <div className='selected-book-cover'>
            <Book bookIndexEntry={bookIndexEntry} />
          </div>
        ) }
      </Card.Body>
    </Card>
  )
}

export default SelectedBook
