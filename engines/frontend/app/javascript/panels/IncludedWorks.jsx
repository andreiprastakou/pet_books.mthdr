import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import BooksListCovers from 'panels/BooksListCovers'
import { fetchMissingBookIndexEntries } from 'store/books/actions'
import {
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
} from 'store/books/selectors'

export const PANEL_ID = 'included-works'

const IncludedWorks = () => {
  const dispatch = useDispatch()
  const bookIndexEntry = useSelector(selectCurrentBookIndexEntry())
  const bookDetails = useSelector(selectCurrentBookDetails())
  const book = bookIndexEntry && bookDetails.id === bookIndexEntry.id
    ? bookDetails
    : null
  const workIds = book?.format === 'collection' ? book.collectedWorkIds || [] : null

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
      panelId={PANEL_ID}
      showControls={false}
    />
  )
}

export default IncludedWorks
