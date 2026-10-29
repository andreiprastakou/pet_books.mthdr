import React, { useContext, useEffect } from 'react'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import useCompactLayout from 'hooks/useCompactLayout'
import BookDetailsCard from 'panels/bookDetails/BookDetailsCard'
import {
  includedWorkIdsFor,
  includedWorksAuthorPlacement,
} from 'panels/bookDetails/includedWorksAuthorPlacement'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'
import {
  fetchBookDetails,
  fetchCurrentBookDetails,
  fetchMissingBookIndexEntries,
} from 'store/books/actions'
import {
  selectBookDetails,
  selectBooksIndexEntry,
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import { selectSeriesRefsByIds } from 'store/series/selectors'
import { selectTagsRefsByIds } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { DEFAULT_COVER_SIZE, SMALLEST_COVER_SIZE } from 'utils/coverSizes'

const useDisplayedBook = bookId => {
  const dispatch = useDispatch()
  const currentIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const indexedEntry = useSelector(selectBooksIndexEntry(bookId))
  const currentDetails = useSelector(selectCurrentBookDetails())
  const storedDetails = useSelector(selectBookDetails(bookId))
  const requestedIndexEntry = bookId ? indexedEntry : currentIndexEntry
  // Current details stay put until the next fetch replaces them. Keep showing
  // that book so the panel does not unmount and collapse the page.
  const bookDetails = (bookId ? storedDetails : currentDetails) || {}
  const displayedIndexEntry = useSelector(selectBooksIndexEntry(bookDetails.id))

  useEffect(() => {
    if (bookId) {
      if (bookDetails.id !== bookId) dispatch(fetchBookDetails(bookId))
      return
    }

    if (requestedIndexEntry && bookDetails.id !== requestedIndexEntry.id)
      dispatch(fetchCurrentBookDetails())
  }, [bookDetails.id, bookId, requestedIndexEntry, dispatch])

  const book = displayedIndexEntry && bookDetails.id === displayedIndexEntry.id
    ? bookDetails
    : null

  return { book, bookIndexEntry: book ? displayedIndexEntry : null }
}

const BookDetails = ({
  bookId = null,
  header = null,
  showCover = true,
  showPublicLists = true,
}) => {
  const dispatch = useDispatch()
  const { book, bookIndexEntry } = useDisplayedBook(bookId)
  const compact = useCompactLayout()
  const authorRefs = useSelector(selectAuthorsRefsByIds(bookIndexEntry?.authorIds || []), shallowEqual)
  const seriesRefs = useSelector(selectSeriesRefsByIds(book?.seriesIds || []), shallowEqual)
  const tags = useSelector(selectTagsRefsByIds(book?.tagIds || []), shallowEqual)
  const booksIndex = useSelector(state => state.storeBooks.booksIndex)
  const includedWorkIds = includedWorkIdsFor(book)
  const authorPlacement = includedWorksAuthorPlacement(includedWorkIds, booksIndex)
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
    if (!includedWorkIds?.length) return

    dispatch(fetchMissingBookIndexEntries(includedWorkIds))
  }, [dispatch, includedWorkIds])

  if (!book || !bookIndexEntry || !routesReady) return null

  return (
    <BookDetailsCard
      authorPagePath={authorPagePath}
      authorPlacement={authorPlacement}
      authorRefs={authorRefs}
      book={book}
      bookIndexEntry={bookIndexEntry}
      bookPagePath={bookPagePath}
      booksPagePath={booksPagePath}
      compact={compact}
      coverSize={compact ? SMALLEST_COVER_SIZE : DEFAULT_COVER_SIZE}
      header={header}
      includedWorkIds={includedWorkIds}
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
  bookId: PropTypes.number,
  header: PropTypes.node,
  showCover: PropTypes.bool,
  showPublicLists: PropTypes.bool,
}

export default BookDetails
