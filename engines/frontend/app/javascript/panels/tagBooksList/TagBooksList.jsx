import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { Card } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'
import PropTypes from 'prop-types'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCurrentTagIndexEntry } from 'store/tags/selectors'
import {
  selectBookIds,
  selectBooksTotal,
  selectPage,
  selectPerPage,
  selectSortBy,
} from 'widgets/booksListLinear/selectors'
import { setRequestedBookId } from 'store/books/actions'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'
import WidgetConfigurer from 'widgets/booksListLinear/WidgetConfigurer'
import BookIndexEntry from 'widgets/booksListLinear/components/BookIndexEntry'
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

export const WIDGET_ID = 'tag-books-list'

// eslint-disable-next-line max-lines-per-function, max-statements
const TagBooksList = ({ configure = true, header = null, showControls = true }) => {
  const dispatch = useDispatch()
  const bookIds = useSelector(selectBookIds())
  const totalCount = useSelector(selectBooksTotal())
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const currentBookId = useSelector(selectCurrentBookId())
  const tag = useSelector(selectCurrentTagIndexEntry())
  const ref = useRef(null)
  const hasActivated = useRef(false)
  const {
    pageState: { activeWidgetId, registeredWidgetIds },
    actions: {
      activateWidget,
      deactivateWidget,
      registerWidget,
      switchToIndexPage,
      unregisterWidget,
    },
  } = useContext(UrlStoreContext)
  const isActive = activeWidgetId === WIDGET_ID
  const booksKey = bookIds.join(',')
  const previousBooksKey = useRef(booksKey)
  const pendingPageSelection = useRef(null)

  useEffect(() => {
    registerWidget(WIDGET_ID)
    return () => unregisterWidget(WIDGET_ID)
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
    if (hasActivated.current || !registeredWidgetIds.includes(WIDGET_ID)) return
    hasActivated.current = true
    activateWidget(WIDGET_ID)
    ref.current?.focus()
  }, [activateWidget, registeredWidgetIds])

  useEffect(() => {
    const handleOutsideInteraction = event => {
      if (!ref.current?.contains(event.target)) deactivateWidget(WIDGET_ID)
    }

    document.addEventListener('focusin', handleOutsideInteraction)
    document.addEventListener('click', handleOutsideInteraction)
    return () => {
      document.removeEventListener('focusin', handleOutsideInteraction)
      document.removeEventListener('click', handleOutsideInteraction)
    }
  }, [])

  const handleClick = useCallback(event => {
    activateWidget(WIDGET_ID)
    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl) ref.current?.focus()
  }, [activateWidget])
  const handleFocus = useCallback(() => activateWidget(WIDGET_ID), [activateWidget])

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
    <>
      { configure ? <LocalUrlStoreConfigurer /> : null }

      { configure ? <WidgetConfigurer selectFirstBook={false} /> : null }

      <Card
        aria-label='Books'
        className={`tag-books-list-widget panel--widget ${isActive ? 'active' : ''}`}
        onClick={handleClick}
        onFocusCapture={handleFocus}
        onKeyDown={handleKeyDown}
        ref={ref}
        tabIndex={0}
      >
        <Card.Header className='panel--header'>
          <span>
            { header || (
              <>
                <a href='/tags'>
                  { 'Tags' }
                </a>

                <span className='tag-books-list-widget-separator'>
                  { '/' }
                </span>

                <span title={tag?.name}>
                  { `#${tag?.name || ''}` }
                </span>
              </>
            ) }
          </span>

          { totalCount > 0 ? (
            <span className='tag-books-list-count-badge'>
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

        <Card.Body className='tag-books-list-widget-body'>
          <div className='tag-books-list'>
            { rows.map(row => (
              <div
                className='tag-books-list-row'
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
    </>
  )
}

TagBooksList.propTypes = {
  configure: PropTypes.bool,
  header: PropTypes.node,
  showControls: PropTypes.bool,
}

export default TagBooksList
