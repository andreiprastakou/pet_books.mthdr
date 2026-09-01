import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { Card } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import { selectCurrentBookId } from 'store/axis/selectors'
import BookIndexEntry from 'components/books/BookIndexEntry'
import {
  selectBookIds,
  selectBooksTotal,
  selectPage,
  selectPerPage,
  selectSortBy,
} from 'store/booksList/selectors'
import { setRequestedBookId } from 'store/books/actions'
import Pagination from 'components/Pagination'
import SortingDropdown from 'components/SortingDropdown'
import UrlStoreContext from 'store/urlStore/Context'
import {
  GRID_ROW_SIZE,
  isBlocked,
  keyType,
  pageSelection,
  targetSelection,
} from 'utils/paginatedGridNavigation'

export const PANEL_ID = 'books-list-covers'

// eslint-disable-next-line max-lines-per-function, max-statements
const BooksListCovers = ({ header = null, showControls = true }) => {
  const dispatch = useDispatch()
  const bookIds = useSelector(selectBookIds())
  const totalCount = useSelector(selectBooksTotal())
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const hasActivated = useRef(false)
  const {
    pageState: { activePanelId, registeredPanelIds },
    actions: {
      activatePanel,
      deactivatePanel,
      registerPanel,
      switchToIndexPage,
      unregisterPanel,
    },
  } = useContext(UrlStoreContext)
  const isActive = activePanelId === PANEL_ID
  const booksKey = bookIds.join(',')
  const previousBooksKey = useRef(booksKey)
  const pendingPageSelection = useRef(null)

  useEffect(() => {
    registerPanel(PANEL_ID)
    return () => unregisterPanel(PANEL_ID)
  }, [])

  useEffect(() => {
    const pending = pendingPageSelection.current
    const booksChanged = previousBooksKey.current !== booksKey
    if (!booksChanged || bookIds.length === 0) return

    if (pending?.page === page && pending.booksKey !== booksKey) {
      pendingPageSelection.current = null
      dispatch(setRequestedBookId(bookIds[Math.min(pending.index, bookIds.length - 1)]))
    } else if (!bookIds.includes(currentBookId))
      dispatch(setRequestedBookId(bookIds[0]))
    previousBooksKey.current = booksKey
  }, [bookIds, booksKey, currentBookId, dispatch, page])

  useEffect(() => {
    if (hasActivated.current || !registeredPanelIds.includes(PANEL_ID)) return
    hasActivated.current = true
    activatePanel(PANEL_ID)
    ref.current?.focus()
  }, [activatePanel, registeredPanelIds])

  useEffect(() => {
    const handleOutsideInteraction = event => {
      if (!ref.current?.contains(event.target)) deactivatePanel(PANEL_ID)
    }

    document.addEventListener('focusin', handleOutsideInteraction)
    document.addEventListener('click', handleOutsideInteraction)
    return () => {
      document.removeEventListener('focusin', handleOutsideInteraction)
      document.removeEventListener('click', handleOutsideInteraction)
    }
  }, [])

  const handleClick = useCallback(event => {
    activatePanel(PANEL_ID)
    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl) ref.current?.focus()
  }, [activatePanel])
  const handleFocus = useCallback(() => activatePanel(PANEL_ID), [activatePanel])

  const handleKeyDown = useCallback(event => {
    const type = keyType(event.key)
    const index = bookIds.indexOf(currentBookId)
    const lastIndex = bookIds.length - 1
    const lastPage = Math.ceil(totalCount / perPage)
    if (!isActive || index < 0 || !type ||
      isBlocked({ type, index, lastIndex, page, lastPage })) return

    event.preventDefault()
    event.stopPropagation()

    if (type === 'pageUp' || type === 'pageDown') {
      const target = pageSelection({ type, index, page, perPage, totalCount })
      pendingPageSelection.current = {
        booksKey,
        ...target,
      }
      switchToIndexPage(target.page, perPage)
      return
    }

    const target = targetSelection({
      type, index, lastIndex, page, perPage, totalCount,
    })
    if (target.page !== page) {
      pendingPageSelection.current = { booksKey, ...target }
      switchToIndexPage(target.page, perPage)
      return
    }

    dispatch(setRequestedBookId(bookIds[target.index]))
  }, [
    bookIds, booksKey, currentBookId, dispatch, isActive, page, perPage,
    switchToIndexPage, totalCount,
  ])

  const rows = [...Array(Math.ceil(bookIds.length / GRID_ROW_SIZE)).keys()]
    .map(index => bookIds.slice(index * GRID_ROW_SIZE, (index + 1) * GRID_ROW_SIZE))

  return (
    <Card
      aria-label='Books'
      className={`panel--books-list-covers panel--widget ${isActive ? 'active' : ''}`}
      onClick={handleClick}
      onFocusCapture={handleFocus}
      onKeyDown={handleKeyDown}
      ref={ref}
      tabIndex={0}
    >
      <Card.Header className='panel--header'>
        <span>
          { header }
        </span>

        { totalCount > 0 ? (
          <span className='panel-header-counter'>
            { totalCount }
          </span>
          ) : null }

        { showControls ? (
          <>
            <SortingDropdown
              selectSortBy={selectSortBy}
              sortOptions={['popularity', 'year', 'random', 'name']}
            />

            <Pagination
              selectPage={selectPage}
              selectPerPage={selectPerPage}
              selectTotal={selectBooksTotal}
            />
          </>
          ) : null }
      </Card.Header>

      <Card.Body className='panel--body'>
        <div className='books-list'>
          { bookIds.length === 0 ? (
            <div className='books-list-empty'>
              { 'No books' }
            </div>
          ) : rows.map(row => (
            <div
              className='books-list-row'
              key={row.join('-')}
            >
              { row.map(bookId => (
                <BookIndexEntry
                  id={bookId}
                  key={bookId}
                  showYear
                />
                )) }
            </div>
            )) }
        </div>
      </Card.Body>
    </Card>
  )
}

BooksListCovers.propTypes = {
  header: PropTypes.node,
  showControls: PropTypes.bool,
}

export default BooksListCovers
