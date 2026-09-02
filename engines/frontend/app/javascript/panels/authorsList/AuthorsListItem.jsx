import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import classNames from 'classnames'

import { selectSortBy } from 'pages/authorsPage/selectors'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import ImageContainer from 'components/ImageContainer'
import UrlStoreContext from 'store/urlStore/Context'
import { DEFAULT_AUTHOR_SIZE, authorSizeClass, authorSizeType } from 'utils/authorSizes'

const AuthorsListItem = ({ author, size = DEFAULT_AUTHOR_SIZE }) => {
  const selectedAuthorId = useSelector(selectCurrentAuthorId())
  const isSelected = author.id === selectedAuthorId
  const ref = useRef(null)

  const { actions: { showAuthor } } = useContext(UrlStoreContext)
  const sortBy = useSelector(selectSortBy())

  useEffect(() => {
    if (!isSelected || !ref.current) return

    const list = ref.current.closest('.authors-list')
    if (!list) return

    const itemRect = ref.current.getBoundingClientRect()
    const listRect = list.getBoundingClientRect()
    if (itemRect.top < listRect.top)
      list.scrollTop -= listRect.top - itemRect.top
    else if (itemRect.bottom > listRect.bottom)
      list.scrollTop += itemRect.bottom - listRect.bottom
  }, [isSelected])

  const handleClick = useCallback(() => showAuthor(author.id), [showAuthor, author.id])

  return (
    <div
      className='author-item-container'
      ref={ref}
    >
      <div
        className={classNames('authors-list-item', authorSizeClass(size), { 'selected': isSelected })}
        onClick={handleClick}
        title={author.fullname}
      >
        { author.thumbUrl ? (
          <ImageContainer
            classes='thumb'
            url={author.thumbUrl}
          />
        ) : (
          <div className='thumb author-placeholder'>
            <div className='author-name'>
              { author.fullname }
            </div>

            <div className='author-years'>
              { author.birthYear }
            </div>
          </div>
        ) }

        { author.thumbUrl ? (
          <>
            <div className='author-name'>
              { author.fullname }
            </div>

            { sortBy === 'years' &&
              <div className='author-years'>
                { author.birthYear }
              </div> }

            { sortBy === 'popularity' &&
              <div className='author-rank'>
                { `#${author.rank}` }
              </div> }
          </>
        ) : null }
      </div>
    </div>
  )
}

AuthorsListItem.propTypes = {
  author: PropTypes.object.isRequired,
  size: authorSizeType,
}

export default AuthorsListItem
