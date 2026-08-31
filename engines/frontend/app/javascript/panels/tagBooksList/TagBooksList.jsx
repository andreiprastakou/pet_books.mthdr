import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { Card } from 'react-bootstrap'
import { useDispatch, useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCurrentTagIndexEntry } from 'store/tags/selectors'
import {
  selectBookIds,
  selectBooksTotal,
  selectPage,
  selectPerPage,
} from 'widgets/booksListLinear/selectors'
import { setRequestedBookId } from 'store/books/actions'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'
import WidgetConfigurer from 'widgets/booksListLinear/WidgetConfigurer'
import BookIndexEntry from 'widgets/booksListLinear/components/BookIndexEntry'
import Pagination from 'sidebar/booksListLinearControls/Pagination'
import SortingDropdown from 'sidebar/booksListLinearControls/SortingDropdown'
import UrlStoreContext from 'store/urlStore/Context'

export const WIDGET_ID = 'tag-books-list'
const ROW_SIZE = 4

const keyType = key => {
  if (key === 'ArrowLeft' || key === 'Left') return 'left'
  if (key === 'ArrowRight' || key === 'Right') return 'right'
  if (key === 'ArrowUp' || key === 'Up') return 'up'
  if (key === 'ArrowDown' || key === 'Down') return 'down'
  if (key === 'PageUp') return 'pageUp'
  if (key === 'PageDown') return 'pageDown'
  return null
}

const isBlocked = ({ type, index, lastIndex, page, lastPage }) => (
  (type === 'left' && index % ROW_SIZE === 0) ||
  (type === 'right' && (index % ROW_SIZE === ROW_SIZE - 1 || index === lastIndex)) ||
  (type === 'pageUp' && page <= 1) ||
  (type === 'pageDown' && page >= lastPage)
)

const targetIndex = (type, index, lastIndex) => {
  if (type === 'left') return index - 1
  if (type === 'right') return index + 1
  if (type === 'up') return Math.max(index - ROW_SIZE, 0)
  return Math.min(index + ROW_SIZE, lastIndex)
}

// eslint-disable-next-line max-lines-per-function, max-statements
const TagBooksList = () => {
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
      const nextPage = page + (type === 'pageDown' ? 1 : -1)
      const nextLength = Math.min(perPage, totalCount - ((nextPage - 1) * perPage))
      pendingPageSelection.current = {
        booksKey,
        index: Math.min(index, nextLength - 1),
        page: nextPage,
      }
      switchToIndexPage(nextPage, perPage)
      return
    }

    dispatch(setRequestedBookId(bookIds[targetIndex(type, index, lastIndex)]))
  }, [
    bookIds, booksKey, currentBookId, dispatch, isActive, page, perPage,
    switchToIndexPage, totalCount,
  ])

  const rows = [...Array(Math.ceil(bookIds.length / ROW_SIZE)).keys()]
    .map(index => bookIds.slice(index * ROW_SIZE, (index + 1) * ROW_SIZE))

  return (
    <>
      <LocalUrlStoreConfigurer />

      <WidgetConfigurer selectFirstBook={false} />

      <Card
        aria-label='Books'
        className={`tag-books-list-widget sidebar-card-widget ${isActive ? 'active' : ''}`}
        onClick={handleClick}
        onFocusCapture={handleFocus}
        onKeyDown={handleKeyDown}
        ref={ref}
        tabIndex={0}
      >
        <Card.Header className='widget-title tag-books-list-widget-header'>
          <span className='tag-books-list-widget-title'>
            <a href='/tags'>
              { 'Tags' }
            </a>

            <span className='tag-books-list-widget-separator'>
              { ' / ' }
            </span>

            <span title={tag?.name}>
              { `#${tag?.name || ''}` }
            </span>
          </span>

          { totalCount > 0 ? (
            <span className='tag-books-list-count-badge'>
              { totalCount }
            </span>
          ) : null }

          <SortingDropdown />

          <Pagination />
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

export default TagBooksList
