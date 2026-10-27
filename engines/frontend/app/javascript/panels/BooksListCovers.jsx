import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { Card } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import { setCurrentBookId } from 'store/axis/actions'
import { selectCurrentBookId } from 'store/axis/selectors'
import BooksListCoversGrid from 'panels/booksListCovers/BooksListCoversGrid'
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
import useCompactLayout from 'hooks/useCompactLayout'
import useFittedSize from 'hooks/useFittedSize'
import { bookIdFromWindowLocation } from 'utils/bookIdFromLocation'
import { notNullish } from 'utils/nullish'
import { coverSizeForWidth } from 'utils/coverSizes'
import {
  GRID_ROW_SIZE,
  isBlocked,
  keyType,
  pageSelection,
  targetSelection,
} from 'utils/paginatedGridNavigation'

const COMPACT_ROW_SIZE = 3

export const PANEL_ID = 'books-list-covers'
export const BOOK_SORT_OPTIONS = ['popularity', 'year', 'random', 'title']
export const READS_SORT_OPTIONS = ['latest', ...BOOK_SORT_OPTIONS]

// Both match .books-list-row: its `gap`, and the padding .book-case puts
// around the cover it centers.
const GRID_GAP = 10
const GRID_CELL_INSET = 10

// eslint-disable-next-line max-lines-per-function, max-statements
const BooksListCovers = ({
  bookIds: bookIdsProp = null,
  bookLabels = null,
  className = '',
  header = null,
  headerAction = null,
  label = 'Books',
  onSelectBook = null,
  panelId = PANEL_ID,
  rowSize = GRID_ROW_SIZE,
  selectedBookId = null,
  showControls = true,
  sortOptions = BOOK_SORT_OPTIONS,
}) => {
  const usesStoreList = bookIdsProp === null
  const dispatch = useDispatch()
  const storeBookIds = useSelector(selectBookIds())
  const storeTotalCount = useSelector(selectBooksTotal())
  const bookIds = usesStoreList ? storeBookIds : bookIdsProp
  const totalCount = usesStoreList ? storeTotalCount : bookIdsProp.length
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const currentBookId = useSelector(selectCurrentBookId())
  const compact = useCompactLayout()
  const columns = compact ? Math.min(rowSize, COMPACT_ROW_SIZE) : rowSize
  const ref = useRef(null)
  const [gridRef, coverSize] = useFittedSize({
    columns, gap: GRID_GAP, inset: GRID_CELL_INSET, sizeForWidth: coverSizeForWidth,
  })
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
  const isActive = activePanelId === panelId
  const booksKey = bookIds.join(',')
  const previousBooksKey = useRef(booksKey)
  const pendingPageSelection = useRef(null)

  useEffect(() => {
    if (usesStoreList) registerPanel(panelId)

    return () => {
      if (usesStoreList) unregisterPanel(panelId)
    }
  }, [panelId, registerPanel, unregisterPanel, usesStoreList])

  useEffect(() => {
    if (!usesStoreList) return

    const pending = pendingPageSelection.current
    const booksChanged = previousBooksKey.current !== booksKey
    if (!booksChanged || bookIds.length === 0) return

    if (pending?.page === page && pending.booksKey !== booksKey) {
      pendingPageSelection.current = null
      dispatch(setRequestedBookId(bookIds[Math.min(pending.index, bookIds.length - 1)]))
    } else if (!bookIds.includes(currentBookId)) {
      const preferred = bookIdFromWindowLocation()
      if (notNullish(preferred) && bookIds.includes(preferred))
        dispatch(setCurrentBookId(preferred))
      else
        dispatch(setRequestedBookId(bookIds[0]))
    }
    previousBooksKey.current = booksKey
  }, [bookIds, booksKey, currentBookId, dispatch, page, usesStoreList])

  useEffect(() => {
    if (!usesStoreList || hasActivated.current || !registeredPanelIds.includes(panelId)) return
    hasActivated.current = true
    activatePanel(panelId)
    ref.current?.focus()
  }, [activatePanel, panelId, registeredPanelIds, usesStoreList])

  useEffect(() => {
    const handleOutsideInteraction = event => {
      if (!ref.current?.contains(event.target)) deactivatePanel(panelId)
    }

    if (usesStoreList) {
      document.addEventListener('focusin', handleOutsideInteraction)
      document.addEventListener('click', handleOutsideInteraction)
    }

    return () => {
      document.removeEventListener('focusin', handleOutsideInteraction)
      document.removeEventListener('click', handleOutsideInteraction)
    }
  }, [deactivatePanel, panelId, usesStoreList])

  const handleClick = useCallback(event => {
    if (!usesStoreList) return

    activatePanel(panelId)
    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl) ref.current?.focus()
  }, [activatePanel, panelId, usesStoreList])
  const handleFocus = useCallback(() => {
    if (usesStoreList) activatePanel(panelId)
  }, [activatePanel, panelId, usesStoreList])

  const handleKeyDown = useCallback(event => {
    const type = keyType(event.key)
    const index = bookIds.indexOf(currentBookId)
    const lastIndex = bookIds.length - 1
    const lastPage = Math.ceil(totalCount / perPage)
    if (!usesStoreList || !isActive || index < 0 || !type ||
      isBlocked({ type, index, lastIndex, page, lastPage, rowSize: columns })) return

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
      type, index, page, perPage, rowSize: columns, totalCount,
    })
    if (target.page !== page) {
      pendingPageSelection.current = { booksKey, ...target }
      switchToIndexPage(target.page, perPage)
      return
    }

    dispatch(setRequestedBookId(bookIds[target.index]))
  }, [
    bookIds, booksKey, columns, currentBookId, dispatch, isActive, page, perPage,
    switchToIndexPage, totalCount, usesStoreList,
  ])

  return (
    <Card
      aria-label={label}
      className={`panel--books-list-covers panel--widget ${className} ${isActive ? 'active' : ''}`}
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
            <div className='books-list-header-sort'>
              { headerAction }

              <SortingDropdown
                selectSortBy={selectSortBy}
                sortOptions={sortOptions}
              />
            </div>

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
          <BooksListCoversGrid
            bookIds={bookIds}
            bookLabels={bookLabels}
            coverSize={coverSize}
            gridRef={gridRef}
            onSelectBook={onSelectBook}
            rowSize={columns}
            selectedBookId={selectedBookId}
          />
        </div>
      </Card.Body>
    </Card>
  )
}

BooksListCovers.propTypes = {
  bookIds: PropTypes.arrayOf(PropTypes.number),
  bookLabels: PropTypes.object,
  className: PropTypes.string,
  header: PropTypes.node,
  headerAction: PropTypes.node,
  label: PropTypes.string,
  onSelectBook: PropTypes.func,
  panelId: PropTypes.string,
  rowSize: PropTypes.number,
  selectedBookId: PropTypes.number,
  showControls: PropTypes.bool,
  sortOptions: PropTypes.arrayOf(PropTypes.string),
}

export default BooksListCovers
