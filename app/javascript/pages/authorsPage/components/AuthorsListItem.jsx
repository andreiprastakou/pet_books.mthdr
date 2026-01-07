import React, { useContext, useEffect, useRef } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Col } from 'react-bootstrap'
import classNames from 'classnames'

import { selectSortBy } from 'pages/authorsPage/selectors'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import { selectAuthorDefaultImageUrl } from 'store/authors/selectors'
import ImageContainer from 'components/ImageContainer'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorsListItem = (props) => {
  const { author } = props
  const selectedAuthorId = useSelector(selectCurrentAuthorId())
  const isSelected = author.id == selectedAuthorId
  const ref = useRef(null)
  const defaultPhotoUrl = useSelector(selectAuthorDefaultImageUrl())

  const { actions: { showAuthor } } = useContext(UrlStoreContext)
  const sortBy = useSelector(selectSortBy())

  useEffect(() => {
    if (isSelected) ref.current?.scrollIntoView()
  })

  return (
    <Col key={ author.id } sm={3} ref={ ref } className='author-item-container'>
      <div className={ classNames('authors-list-item', { 'selected': isSelected })}
           onClick={ () => showAuthor(author.id) }
           title={ author.fullname }>
        <ImageContainer className='thumb' url={ author.thumbUrl || defaultPhotoUrl }/>

        <div className='author-name'>{ author.fullname }</div>

        { sortBy == 'years' &&
          <div className='author-years'>{ author.birthYear }</div>
        }

        { sortBy == 'popularity' &&
          <div className='author-rank'>#{ author.rank }</div>
        }
      </div>
    </Col>
  )
}

export default AuthorsListItem
