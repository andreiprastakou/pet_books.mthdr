import React, { useCallback, useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import { Col } from 'react-bootstrap'
import classNames from 'classnames'

import { selectSortBy } from 'pages/authorsPage/selectors'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import { selectAuthorDefaultImageUrl } from 'store/authors/selectors'
import ImageContainer from 'components/ImageContainer'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorsListItem = ({ author }) => {
  const selectedAuthorId = useSelector(selectCurrentAuthorId())
  const isSelected = author.id === selectedAuthorId
  const ref = useRef(null)
  const defaultPhotoUrl = useSelector(selectAuthorDefaultImageUrl())

  const { actions: { showAuthor } } = useContext(UrlStoreContext)
  const sortBy = useSelector(selectSortBy())

  useEffect(() => {
    if (isSelected) ref.current?.scrollIntoView()
  })

  const handleClick = useCallback(() => showAuthor(author.id), [showAuthor, author.id])

  return (
    <Col
      className='author-item-container'
      key={author.id}
      ref={ref}
      sm={3}
    >
      <div
        className={classNames('authors-list-item', { 'selected': isSelected })}
        onClick={handleClick}
        title={author.fullname}
      >
        <ImageContainer
          classes='thumb'
          url={author.thumbUrl || defaultPhotoUrl}
        />

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
      </div>
    </Col>
  )
}

AuthorsListItem.propTypes = {
  author: PropTypes.object.isRequired,
}

export default AuthorsListItem
