import sortBy from 'lodash/sortBy'
import React, { useContext, useEffect, useCallback } from 'react'
import { Card } from 'react-bootstrap'
import { shallowEqual, useSelector, useDispatch } from 'react-redux'
import PropTypes from 'prop-types'

import Toolbar from 'panels/authorCard/Toolbar'
import ImageContainer from 'components/ImageContainer'
import TagBadge from 'components/TagBadge'

import orders from 'pages/authorsPage/sortOrders'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import { selectAuthorFull, selectAuthorDefaultImageUrl } from 'store/authors/selectors'
import { fetchAuthorFull } from 'store/authors/actions'
import { selectTagsRefsByIds, selectVisibleTags } from 'store/tags/selectors'
import { setImageSrc } from 'modals/imageFullShow/actions'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorCardHeader = ({ header, name }) => header || (
  <>
    <a href='/authors'>
      { 'Authors' }
    </a>

    <span className='author-card-panel-separator'>
      { '/ ' }
    </span>

    <span
      className='author-card-panel-title'
      title={name}
    >
      { name }
    </span>
  </>
)

const AuthorCardWrap = ({ linkToAuthorPage, showPicture, header }) => {
  const authorId = useSelector(selectCurrentAuthorId())
  const authorFull = useSelector(selectAuthorFull(authorId))
  const dispatch = useDispatch()
  useEffect(() => {
    if (authorId && !authorFull) dispatch(fetchAuthorFull(authorId))
  }, [authorId])

  if (!authorFull) return null
  return (
    <AuthorCard
      authorFull={authorFull}
      header={header}
      linkToAuthorPage={linkToAuthorPage}
      showPicture={showPicture}
    />
  )
}

const AuthorCard = ({
  authorFull,
  linkToAuthorPage = true,
  showPicture = true,
  header = null,
}) => {
  const { routes: { authorsPagePath }, routesReady } = useContext(UrlStoreContext)
  const dispatch = useDispatch()
  const tags = useSelector(selectTagsRefsByIds(authorFull.tagIds), shallowEqual)
  const visibleTags = useSelector(selectVisibleTags(tags), shallowEqual)
  const sortedTags = sortBy(visibleTags, tag => tag.connectionsCount)
  const defaultPhotoUrl = useSelector(selectAuthorDefaultImageUrl())

  const handleImageClick = useCallback(() => {
    dispatch(setImageSrc(authorFull.imageUrl))
  }, [authorFull.imageUrl])

  if (!routesReady) return null

  return (
    <Card
      className={`panel--author-card panel--widget ${
        showPicture ? '' : 'author-card-without-picture'
      }`}
    >
      <Card.Header className='panel--header'>
        <AuthorCardHeader
          header={header}
          name={authorFull.fullname}
        />
      </Card.Header>

      <Card.Body className='panel--body'>
        { showPicture ? (
          <ImageContainer
            classes='author-image'
            onClick={handleImageClick}
            url={authorFull.thumbUrl || defaultPhotoUrl}
          />
        ) : null }

        <div className='details-right'>
          <div className='author-name'>
            { authorFull.fullname }
          </div>

          <div className='author-card-text'>
            { authorFull.birthYear ? (
              <div>
                { renderLifetime(authorFull, authorsPagePath) }
              </div>
            ) : null}
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

          <Toolbar
            authorFull={authorFull}
            linkToAuthorPage={linkToAuthorPage}
          />
        </div>
      </Card.Body>
    </Card>
  )
}

AuthorCardWrap.propTypes = {
  header: PropTypes.node,
  linkToAuthorPage: PropTypes.bool,
  showPicture: PropTypes.bool,
}

AuthorCardHeader.propTypes = {
  header: PropTypes.node,
  name: PropTypes.string.isRequired,
}

AuthorCard.propTypes = {
  authorFull: PropTypes.object.isRequired,
  header: PropTypes.node,
  linkToAuthorPage: PropTypes.bool,
  showPicture: PropTypes.bool,
}

const renderLifetime = (authorFull, authorsPath) => {
  if (!authorFull.birthYear)  return null

  const age = authorFull.deathYear
    ? authorFull.deathYear - authorFull.birthYear
    : new Date().getFullYear() - authorFull.birthYear
  return(
    <>
      { authorFull.birthYear }

      { authorFull.deathYear ? `-${authorFull.deathYear}` : '' }

      { ' (' }

      <a href={authorsPath({ authorId: authorFull.id, sortOrder: orders.BY_YEAR_ASCENDING })}>
        { `age: ${age}` }
      </a>

      { ')' }
    </>
  )
}

export default AuthorCardWrap
