import { sortBy } from 'lodash'
import PropTypes from 'prop-types'
import React, { useContext, useEffect, useRef, useCallback } from 'react'
import { useSelector, useDispatch } from 'react-redux'

import TagBadge from 'components/TagBadge'
import PopularityBadge from 'components/PopularityBadge'
import BookToolbar from 'components/BookToolbar'
import UrlStoreContext from 'store/urlStore/Context'
import { selectAuthorRef } from 'store/authors/selectors'
import { selectTagsRefsByIds, selectVisibleTags } from 'store/tags/selectors'
import { setImageSrc } from 'modals/imageFullShow/actions'

const BookSelected = ({ bookIndexEntry }) => {
  const { id } = bookIndexEntry
  const authorRef = useSelector(selectAuthorRef(bookIndexEntry.authorId))
  const dispatch = useDispatch()
  const tags = useSelector(selectTagsRefsByIds(bookIndexEntry.tagIds))
  const visibleTags = useSelector(selectVisibleTags(tags))
  const sortedTags = sortBy(visibleTags, tag => -tag.connectionsCount)
  const ref = useRef(null)
  const { routes: { authorPagePath }, routesReady } = useContext(UrlStoreContext)

  useEffect(() => ref.current?.focus(), [])

  if (!routesReady) return null

  return (
    <div
      className='book-case selected'
      ref={ref}
    >
      <div className='book-details'>
        <a
          className='book-author'
          href={authorPagePath(authorRef.id, { bookId: id })}
          title={authorRef.fullname}
        >
          { authorRef.fullname }
        </a>

        <div
          className='book-title'
          title={bookIndexEntry.title}
        >
          { bookIndexEntry.title }
        </div>

        <div className='book-tags'>
          { sortedTags.map(tag =>
            (<TagBadge
              id={tag.id}
              key={tag.id}
              text={tag.name}
              variant='dark'
             />)
          ) }
        </div>

        <div className='book-stats'>
          { Boolean(bookIndexEntry.popularity) && bookIndexEntry.globalRank ? (
            <PopularityBadge
              points={bookIndexEntry.popularity}
              rank={bookIndexEntry.globalRank}
            />
          ) : null}
        </div>

        <BookToolbar book={bookIndexEntry} />
      </div>
    </div>
  )
}

BookSelected.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
}

export default BookSelected
