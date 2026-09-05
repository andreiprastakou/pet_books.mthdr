import React, { useContext, useEffect } from 'react'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import BookDetailsCard from 'panels/bookDetails/BookDetailsCard'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import { fetchCurrentBookDetails } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import { selectSeriesRefsByIds } from 'store/series/selectors'
import { selectTagsRefsByIds } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const BookDetails = ({ header = null, showCover = true, showPublicLists = true }) => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry?.authorIds || []), shallowEqual)
  const seriesRefs = useSelector(selectSeriesRefsByIds(bookDetails.seriesIds || []), shallowEqual)
  const tags = useSelector(selectTagsRefsByIds(bookDetails.tagIds || []), shallowEqual)
  const {
    routes: {
      authorPagePath,
      booksPagePath,
      bookPagePath,
      listPagePath,
      seriesPagePath,
    },
    routesReady,
  } = useContext(UrlStoreContext)

  useEffect(() => {
    if (bookIndexEntry && bookDetails.id !== bookIndexEntry.id)
      dispatch(fetchCurrentBookDetails())
  }, [bookIndexEntry?.id, bookDetails.id])

  const book = bookIndexEntry && bookDetails.id === bookIndexEntry.id
    ? bookDetails
    : null

  if (!book || !routesReady) return null

  return (
    <BookDetailsCard
      authorPagePath={authorPagePath}
      authorRefs={authorRefs}
      book={book}
      bookIndexEntry={bookIndexEntry}
      bookPagePath={bookPagePath}
      booksPagePath={booksPagePath}
      header={header}
      listPagePath={listPagePath}
      seriesPagePath={seriesPagePath}
      seriesRefs={seriesRefs}
      showCover={showCover}
      showPublicLists={showPublicLists}
      tags={tags}
    />
  )
}

BookDetails.propTypes = {
  header: PropTypes.node,
  showCover: PropTypes.bool,
  showPublicLists: PropTypes.bool,
}

export default BookDetails
