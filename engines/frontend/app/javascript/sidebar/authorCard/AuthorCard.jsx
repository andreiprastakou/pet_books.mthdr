import { sortBy } from 'lodash'
import React, { useContext, useEffect, useCallback } from 'react'
import { Card } from 'react-bootstrap'
import { useSelector, useDispatch } from 'react-redux'
import PropTypes from 'prop-types'

import Toolbar from 'sidebar/authorCard/Toolbar'
import ImageContainer from 'components/ImageContainer'
import TagBadge from 'components/TagBadge'
import CloseIcon from 'components/icons/CloseIcon'

import orders from 'pages/authorsPage/sortOrders'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import { selectAuthorFull, selectAuthorDefaultImageUrl } from 'store/authors/selectors'
import { fetchAuthorFull } from 'store/authors/actions'
import { selectTagsRefsByIds, selectVisibleTags } from 'store/tags/selectors'
import { setImageSrc } from 'modals/imageFullShow/actions'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorCardWrap = () => {
  const authorId = useSelector(selectCurrentAuthorId())
  const authorFull = useSelector(selectAuthorFull(authorId))
  const dispatch = useDispatch()
  useEffect(() => {
    if (authorId && !authorFull) dispatch(fetchAuthorFull(authorId))
  }, [authorId])

  if (!authorFull) return null
  return (<AuthorCard authorFull={authorFull} />)
}

const AuthorCard = ({ authorFull, onClose = null }) => {
  const { routes: { authorsPagePath }, routesReady } = useContext(UrlStoreContext)
  const dispatch = useDispatch()
  const tags = useSelector(selectTagsRefsByIds(authorFull.tagIds))
  const visibleTags = useSelector(selectVisibleTags(tags))
  const sortedTags = sortBy(visibleTags, tag => tag.connectionsCount)
  const defaultPhotoUrl = useSelector(selectAuthorDefaultImageUrl())

  const handleClose = useCallback(() => {
    if (onClose) onClose()
  }, [onClose])

  const handleImageClick = useCallback(() => {
    dispatch(setImageSrc(authorFull.imageUrl))
  }, [authorFull.imageUrl])

  if (!routesReady) return null

  return (
    <Card className='sidebar-widget-author-card sidebar-card-widget'>
      <Card.Header className='widget-title'>
        { 'Author' }
      </Card.Header>

      { onClose ? <CloseIcon onClick={handleClose} /> : null}

      <Card.Body>
        <ImageContainer
          classes='author-image'
          onClick={handleImageClick}
          url={authorFull.thumbUrl || defaultPhotoUrl}
        />

        <div className='details-right'>
          <div className='author-name'>
            { authorFull.fullname }
          </div>

          <div className='author-card-text'>
            <div>
              { 'Years: ' }

              { renderLifetime(authorFull, authorsPagePath) }
            </div>

            <div>
              { `Popularity: ${authorFull.popularity.toLocaleString()} pts (` }

              <a href={authorsPagePath({ authorId: authorFull.id, sortOrder: orders.BY_RANK_ASCENDING })}>
                { `#${authorFull.rank}` }
              </a>

              { ')' }
            </div>
          </div>

          <div className='author-tags'>
            { sortedTags.map(tag =>
              (<TagBadge
                id={tag.id}
                key={tag.id}
                text={tag.name}
                variant='dark'
               />)
            ) }
          </div>
        </div>

        <Toolbar authorFull={authorFull} />
      </Card.Body>
    </Card>
  )
}

AuthorCard.propTypes = {
  authorFull: PropTypes.object.isRequired,
  onClose: PropTypes.func,
}

const renderLifetime = (authorFull, authorsPath) => {
  if (!authorFull.birthYear)  return null

  const birthLabel = `${authorFull.birthYear}--`
  const age = authorFull.deathYear
    ? authorFull.deathYear - authorFull.birthYear
    : new Date().getFullYear() - authorFull.birthYear
  return(
    <>
      { birthLabel }

      { authorFull.deathYear }

      { ' (' }

      <a href={authorsPath({ authorId: authorFull.id, sortOrder: orders.BY_YEAR_ASCENDING })}>
        { `age: ${age}` }
      </a>

      { ')' }
    </>
  )
}

export default AuthorCardWrap
