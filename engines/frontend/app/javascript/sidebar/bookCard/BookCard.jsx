import { sortBy } from 'lodash'
import React, { useContext } from 'react'
import { useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import { Card } from 'react-bootstrap'

import { selectAuthorRef } from 'store/authors/selectors'
import { selectCurrentBookIndexEntry } from 'store/books/selectors'
import { selectTagsRefsByIds, selectVisibleTags } from 'store/tags/selectors'
import TagBadge from 'components/TagBadge'
import PopularityBadge from 'components/PopularityBadge'
import BookToolbar from 'components/BookToolbar'
import UrlStoreContext from 'store/urlStore/Context'

const BookCardWrap = () => {
  const booksIndexEntry = useSelector(selectCurrentBookIndexEntry())
  if (!booksIndexEntry) return null

  return (<BookCard booksIndexEntry={booksIndexEntry} />)
}

const BookCard = props => {
  const { booksIndexEntry } = props
  const authorRef = useSelector(selectAuthorRef(booksIndexEntry.authorId))
  const tags = useSelector(selectTagsRefsByIds(booksIndexEntry.tagIds))
  const visibleTags = useSelector(selectVisibleTags(tags))
  const { routes: { authorPagePath }, routesReady } = useContext(UrlStoreContext)
  const sortedTags = sortBy(visibleTags, tag => -tag.connectionsCount)

  if (!routesReady || !booksIndexEntry) return null

  return (
    <Card className='sidebar-book-card-widget sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { 'Book' }
      </Card.Header>

      <Card.Body>
        <div className='book-details'>
          <div>
            <a
              className='book-author'
              href={authorPagePath(authorRef.id, { bookId: booksIndexEntry.id })}
              title={authorRef.fullname}
            >
              { authorRef.fullname }
            </a>

            { ' ' }

            <span className='year'>
              { booksIndexEntry.year }
            </span>
          </div>

          <div
            className='book-title'
            title={booksIndexEntry.title}
          >
            { booksIndexEntry.goodreadsUrl ? (
              <a href={booksIndexEntry.goodreadsUrl}>
                { booksIndexEntry.title }
              </a>
            ) : booksIndexEntry.title }
          </div>

          <div className='book-stats'>
            { Boolean(booksIndexEntry.popularity) && booksIndexEntry.globalRank ? (
              <PopularityBadge
                points={booksIndexEntry.popularity}
                rank={booksIndexEntry.globalRank}
              />
            ) : null }
          </div>

          <div className='book-tags'>
            { sortedTags.map(tag => (
              <TagBadge
                id={tag.id}
                key={tag.id}
                text={tag.name}
                variant='dark'
              />
            )) }
          </div>

          <BookToolbar book={booksIndexEntry} />
        </div>
      </Card.Body>
    </Card>
  )
}

BookCard.propTypes = {
  booksIndexEntry: PropTypes.object.isRequired,
}

export default BookCardWrap
