import React, { useContext, useEffect, useRef } from 'react'
import PropTypes from 'prop-types'
import { useSelector, useDispatch } from 'react-redux'
import classnames from 'classnames'

import { selectBookDefaultImageUrl } from 'store/books/selectors'
import { selectCurrentBookId } from 'store/axis/selectors'

import ImageContainer from 'components/ImageContainer'
import UrlStoreContext from 'store/urlStore/Context'

const Book = (props) => {
  const { bookIndexEntry, showYear, ...options } = props
  const dispatch = useDispatch()
  const currentBookId = useSelector(selectCurrentBookId())
  const defaultCoverUrl = useSelector(selectBookDefaultImageUrl())
  const ref = useRef(null)
  const { actions: { showBooksIndexEntry } } = useContext(UrlStoreContext)

  const isCurrent = bookIndexEntry.id == currentBookId
  const coverUrl = bookIndexEntry.coverUrl || defaultCoverUrl
  const classNames = classnames('book-case', { 'selected': isCurrent })

  useEffect(() => {
    if (isCurrent) { ref.current?.scrollIntoView() }
  })

  const handleClick = (e) => {
    showBooksIndexEntry(bookIndexEntry.id)
  }

  return (
    <div className={ classNames } onClick={ handleClick } title={ bookIndexEntry.title } ref={ ref } { ...options }>
      <ImageContainer className='book-cover' url={ coverUrl }/>
      { showYear &&
        <div className='year'>{ bookIndexEntry.year }</div>
      }
    </div>
  );
}

Book.propTypes = {
  bookIndexEntry: PropTypes.object.isRequired,
  showYear: PropTypes.bool,
}

export default Book
