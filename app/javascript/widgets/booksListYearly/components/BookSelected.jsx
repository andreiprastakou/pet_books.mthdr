import { sortBy } from 'lodash'
import React, { useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector, useDispatch } from 'react-redux'
import classnames from 'classnames'

import ImageContainer from 'components/ImageContainer'
import TagBadge from 'components/TagBadge'
import PopularityBadge from 'components/PopularityBadge'
import BookToolbar from 'components/BookToolbar'
import UrlStoreContext from 'store/urlStore/Context'
import { selectAuthorRef } from 'store/authors/selectors'
import {selectBookDefaultImageUrl } from 'store/books/selectors'
import { selectTagsRefsByIds, selectVisibleTags } from 'store/tags/selectors'
import { setImageSrc } from 'modals/imageFullShow/actions'

const BookSelected = (props) => {
  const { bookIndexEntry } = props
  const id = bookIndexEntry.id
  const authorRef = useSelector(selectAuthorRef(bookIndexEntry.authorId))
  const dispatch = useDispatch()
  const defaultCoverUrl = useSelector(selectBookDefaultImageUrl())
  const coverUrl = bookIndexEntry.coverUrl || defaultCoverUrl
  const tags = useSelector(selectTagsRefsByIds(bookIndexEntry.tagIds))
  const visibleTags = useSelector(selectVisibleTags(tags))
  const sortedTags = sortBy(visibleTags, tag => -tag.connectionsCount)
  const ref = useRef(null)
  const { routes: { authorPagePath }, routesReady } = useContext(UrlStoreContext)

  useEffect(() => ref.current?.focus(), [])

  if (!routesReady) return null

  const classNames = classnames('book-case', 'selected')

  return (
    <div className='book-case selected' ref={ ref }>
      <ImageContainer className='book-cover' url={ coverUrl } onClick={ () => dispatch(setImageSrc(bookIndexEntry.coverFullUrl)) }/>

      <div className='book-details'>
        <a href={ authorPagePath(authorRef.id, { bookId: id }) } className='book-author' title={ authorRef.fullname }>
          { authorRef.fullname }
        </a>

        <div className='book-title' title={ bookIndexEntry.title }>
          { bookIndexEntry.title }
        </div>

        <div className='book-tags'>
          { sortedTags.map(tag =>
            <TagBadge text={ tag.name } id={ tag.id } key={ tag.id } variant='dark'/>
          ) }
        </div>

        <div className='book-stats'>
          { Boolean(bookIndexEntry.popularity) && bookIndexEntry.globalRank &&
            <PopularityBadge rank={ bookIndexEntry.globalRank } points={ bookIndexEntry.popularity }/>
          }
        </div>

        <BookToolbar book={ bookIndexEntry }/>
      </div>
    </div>
  );
}

export default BookSelected
