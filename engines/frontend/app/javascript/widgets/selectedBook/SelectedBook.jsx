import React, { useEffect } from 'react'
import { Button, ButtonGroup } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'

import Book from 'components/Book'
import TagBadge from 'components/TagBadge'
import { fetchCurrentBookDetails } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import { selectTagsRefsByIds } from 'store/tags/selectors'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'

const SelectedBook = () => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const tags = useSelector(selectTagsRefsByIds(bookDetails.tagIds || []))

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

  return (
    <>
      <LocalUrlStoreConfigurer />

      { book ? (
        <section className='selected-book sidebar-card-widget'>
          <div className='selected-book-details'>
            <div className='selected-book-heading'>
              <h2>
                { book.title }
              </h2>

              <span>
                { book.yearPublished }
              </span>
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

            <div className='selected-book-annotation'>
              <p>
                { book.summary || '<no information>' }
              </p>
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

          <div className='selected-book-cover'>
            <Book bookIndexEntry={bookIndexEntry} />
          </div>
        </section>
      ) : null }
    </>
  )
}

export default SelectedBook
