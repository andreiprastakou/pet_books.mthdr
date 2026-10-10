import React, { useCallback, useContext, useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import useIncludedWorkSelection from 'panels/includedWorkSelection'
import BooksListCovers from 'panels/BooksListCovers'
import { fetchMissingBookIndexEntries } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import { FORMAT_COLLECTION } from 'utils/coverPalettes'

export const PANEL_ID = 'included-works'

const CollectionWorks = () => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const { actions: { showIncludedWork } } = useContext(UrlStoreContext)
  const book = bookIndexEntry && bookDetails.id === bookIndexEntry.id
    ? bookDetails
    : null
  const includedWorkId = useIncludedWorkSelection(book)
  const workIds = book?.format === FORMAT_COLLECTION ? book.collectedWorkIds || [] : null
  const selectIncludedWork = useCallback(id => {
    if (showIncludedWork) showIncludedWork(id)
  }, [showIncludedWork])

  useEffect(() => {
    if (!workIds?.length) return

    dispatch(fetchMissingBookIndexEntries(workIds))
  }, [dispatch, workIds])

  if (!workIds) return null

  return (
    <BooksListCovers
      bookIds={workIds}
      className='panel--included-works'
      header='Included works'
      label='Included works'
      onSelectBook={selectIncludedWork}
      panelId={PANEL_ID}
      selectedBookId={includedWorkId}
      showControls={false}
    />
  )
}

export default CollectionWorks
