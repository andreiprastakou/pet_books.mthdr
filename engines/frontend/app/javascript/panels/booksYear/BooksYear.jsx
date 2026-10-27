import React, {
  useCallback, useContext, useEffect, useLayoutEffect, useMemo, useRef, useState,
} from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'

import GhostBooks from 'panels/booksYear/GhostBooks'
import YearControl from 'panels/booksYear/YearControl'
import { selectCurrentBookId } from 'store/axis/selectors'
import BookIndexEntry from 'components/books/BookIndexEntry'
import {
  fetchBooks,
  assignFilter,
  assignPage,
  clearListState,
  switchToFirstBook,
} from 'store/booksList/actions'
import { setRequestedBookId } from 'store/books/actions'
import {
  selectBookIds,
  selectBooksTotal,
  selectFilter,
} from 'store/booksList/selectors'
import { selectYears } from 'store/booksYears/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import useCompactLayout from 'hooks/useCompactLayout'
import { bookIdFromWindowLocation } from 'utils/bookIdFromLocation'
import { COVER_SIZES, coverSizeForWidth } from 'utils/coverSizes'
import { notNullish } from 'utils/nullish'

export const PANEL_ID = 'books-list-yearly'

const BOOK_WIDTH = 190
const BOOK_HEIGHT = 270
const CELL_WIDTH = 200
const CELL_HEIGHT = 280
// Matches the compact cover list: three columns, the same gap, and the padding
// around each cover. The case is the cover plus that padding on every side.
const COMPACT_COLUMNS = 3
const COMPACT_GAP = 10
const COMPACT_INSET = 10
const CASE_PADDING = COMPACT_INSET * 2

const compactCoverSize = width => {
  const slot = (width - (COMPACT_GAP * (COMPACT_COLUMNS - 1))) / COMPACT_COLUMNS

  return coverSizeForWidth(slot - COMPACT_INSET)
}

const coverMetrics = size => {
  const cover = COVER_SIZES[size]
  const bookWidth = cover.width + CASE_PADDING
  const bookHeight = cover.height + CASE_PADDING

  return {
    bookHeight,
    bookWidth,
    cellHeight: bookHeight + COMPACT_GAP,
    cellWidth: bookWidth + COMPACT_GAP,
    coverHeight: cover.height,
    coverWidth: cover.width,
  }
}
const VISIBLE_COLUMN_RADIUS = 2
const VISIBLE_ROW_RADIUS = 2
const GHOST_COLUMN_MARGIN = 3
const GHOST_ROW_MARGIN = 2
const defaultTitle = () => 'Books of year'

export const spiralPositions = count => {
  const result = [[0, 0]]
  const directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  let column = 0
  let row = 0
  let directionIndex = 0
  let stepsInDirection = 1

  while (result.length < count) {
    for (let repeat = 0; repeat < 2 && result.length < count; repeat += 1) {
      const [rowStep, columnStep] = directions[directionIndex]
      for (let step = 0; step < stepsInDirection && result.length < count; step += 1) {
        row += rowStep
        column += columnStep
        result.push([column, row])
      }
      directionIndex = (directionIndex + 1) % directions.length
    }
    stepsInDirection += 1
  }

  return result
}

export const buildBookMatrix = (bookIds, selectedId) => {
  const orderedBookIds = selectedId ? [
    selectedId,
    ...bookIds.filter(bookId => bookId !== selectedId),
  ] : []
  const positions = spiralPositions(orderedBookIds.length)
  const coordinatesById = {}
  const idsByCoordinate = {}

  orderedBookIds.forEach((bookId, index) => {
    const coordinate = positions[index]
    coordinatesById[bookId] = coordinate
    idsByCoordinate[coordinate.join(':')] = bookId
  })

  return { coordinatesById, idsByCoordinate, orderedBookIds }
}

// eslint-disable-next-line max-lines-per-function, max-statements
const BooksYear = ({ title = defaultTitle }) => {
  const dispatch = useDispatch()
  const bookIds = useSelector(selectBookIds())
  const totalCount = useSelector(selectBooksTotal())
  const filter = useSelector(selectFilter())
  const years = useSelector(selectYears(), shallowEqual)
  const currentBookId = useSelector(selectCurrentBookId())
  const compact = useCompactLayout()
  const ref = useRef(null)
  const contentRef = useRef(null)
  const [contentSize, setContentSize] = useState({ height: 0, width: 0 })
  const coverSize = compact && contentSize.width > 0 ? compactCoverSize(contentSize.width) : null
  const metrics = coverSize ? coverMetrics(coverSize) : null
  const bookWidth = metrics?.bookWidth ?? BOOK_WIDTH
  const bookHeight = metrics?.bookHeight ?? BOOK_HEIGHT
  const cellWidth = metrics?.cellWidth ?? CELL_WIDTH
  const cellHeight = metrics?.cellHeight ?? CELL_HEIGHT
  const {
    pageState: { activePanelId, registeredPanelIds },
    actions: {
      activatePanel,
      deactivatePanel,
      registerPanel,
      unregisterPanel,
    },
  } = useContext(UrlStoreContext)
  const selectedYear = filter.years?.[0] || years[years.length - 1]
  const isActive = activePanelId === PANEL_ID
  const hasActivated = useRef(false)
  const matrixRef = useRef({ key: null, bookIds: [] })
  const bookIdsKey = bookIds.join(',')
  if (matrixRef.current.key !== bookIdsKey) {
    const preferred = bookIdFromWindowLocation()
    let [selectedId] = bookIds
    if (notNullish(preferred) && bookIds.includes(preferred))
      selectedId = preferred
    else if (bookIds.includes(currentBookId))
      selectedId = currentBookId
    matrixRef.current = { key: bookIdsKey, ...buildBookMatrix(bookIds, selectedId) }
  }
  const { coordinatesById, idsByCoordinate, orderedBookIds: matrixBookIds } = matrixRef.current
  const selectedCoordinate = coordinatesById[currentBookId] || coordinatesById[matrixBookIds[0]] || [0, 0]
  const visibleBookIds = useMemo(() => matrixBookIds.filter(bookId => {
    const [column, row] = coordinatesById[bookId]
    return column >= selectedCoordinate[0] - VISIBLE_COLUMN_RADIUS &&
      column <= selectedCoordinate[0] + VISIBLE_COLUMN_RADIUS &&
      row >= selectedCoordinate[1] - VISIBLE_ROW_RADIUS &&
      row <= selectedCoordinate[1] + VISIBLE_ROW_RADIUS
  }), [coordinatesById, matrixBookIds, selectedCoordinate])

  const cellPosition = useCallback((column, row) => ({
    left: (contentSize.width / 2) + ((column - selectedCoordinate[0]) * cellWidth) - (bookWidth / 2),
    top: (contentSize.height / 2) + ((row - selectedCoordinate[1]) * cellHeight) - (bookHeight / 2),
  }), [bookHeight, bookWidth, cellHeight, cellWidth, contentSize, selectedCoordinate])

  const bookPositions = useMemo(() => matrixBookIds.reduce((result, bookId) => {
    const [column, row] = coordinatesById[bookId]
    result[bookId] = cellPosition(column, row)
    return result
  }, {}), [cellPosition, coordinatesById, matrixBookIds])

  const occupiedKeys = useMemo(
    () => visibleBookIds.map(bookId => coordinatesById[bookId].join(':')),
    [coordinatesById, visibleBookIds]
  )

  useLayoutEffect(() => {
    const content = contentRef.current
    if (!content) return () => false

    const updateSize = () => setContentSize({
      height: content.clientHeight,
      width: content.clientWidth,
    })
    const observer = new ResizeObserver(updateSize)
    observer.observe(content)
    updateSize()

    return () => observer.disconnect()
  }, [])

  useEffect(() => {
    if (bookIds.length > 0 && !bookIds.includes(currentBookId))
      dispatch(switchToFirstBook())
  }, [bookIds, currentBookId, dispatch])

  useEffect(() => {
    registerPanel(PANEL_ID)

    return () => unregisterPanel(PANEL_ID)
  }, [])

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

  const selectYear = useCallback(year => {
    dispatch(clearListState())
    dispatch(assignFilter({ years: [year] }))
    dispatch(assignPage(1))
    dispatch(fetchBooks()).then(() => dispatch(switchToFirstBook()))
  }, [dispatch])

  const handleClick = useCallback(event => {
    activatePanel(PANEL_ID)
    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl)
      ref.current?.focus()
  }, [activatePanel])

  const handleFocus = useCallback(() => activatePanel(PANEL_ID), [activatePanel])

  const handleKeyDown = useCallback(event => {
    const shifts = {
      ArrowDown: [0, 1],
      ArrowLeft: [-1, 0],
      ArrowRight: [1, 0],
      ArrowUp: [0, -1],
    }
    const shift = shifts[event.key]
    if (!shift) return

    const currentCoordinate = coordinatesById[currentBookId] || selectedCoordinate
    const targetCoordinate = [
      currentCoordinate[0] + shift[0],
      currentCoordinate[1] + shift[1],
    ]
    const targetId = idsByCoordinate[targetCoordinate.join(':')]
    if (!targetId) return

    event.preventDefault()
    event.stopPropagation()
    dispatch(setRequestedBookId(targetId))
  }, [coordinatesById, currentBookId, dispatch, idsByCoordinate, selectedCoordinate])

  return (
    <Card
      aria-label='All books'
      className={`panel--books-year panel--widget ${isActive ? 'active' : ''}`}
      onClick={handleClick}
      onFocusCapture={handleFocus}
      onKeyDown={handleKeyDown}
      ref={ref}
      tabIndex={0}
    >
      <Card.Header className='panel--header'>
        <span className='all-books-count-badge'>
          { totalCount }
        </span>

        <span>
          { title(selectedYear) }
        </span>

        <div className='all-books-year'>
          <YearControl
            onChange={selectYear}
            value={selectedYear}
            years={years}
          />
        </div>
      </Card.Header>

      <Card.Body className='panel--body'>
        <div
          className='all-books-list'
          ref={contentRef}
          style={metrics ? {
            '--year-book-height': `${metrics.bookHeight}px`,
            '--year-book-width': `${metrics.bookWidth}px`,
            '--year-cover-height': `${metrics.coverHeight}px`,
            '--year-cover-width': `${metrics.coverWidth}px`,
          } : undefined}
        >
          <GhostBooks
            cellPosition={cellPosition}
            centerCoordinate={selectedCoordinate}
            columnRadius={VISIBLE_COLUMN_RADIUS + GHOST_COLUMN_MARGIN}
            occupiedKeys={occupiedKeys}
            rowRadius={VISIBLE_ROW_RADIUS + GHOST_ROW_MARGIN}
          />

          {visibleBookIds.map(bookId => (
            <BookIndexEntry
              id={bookId}
              key={bookId}
              scrollIntoView={false}
              showYear={false}
              size={coverSize || undefined}
              style={bookPositions[bookId]}
            />
            ))}
        </div>
      </Card.Body>
    </Card>
  )
}

BooksYear.propTypes = {
  title: PropTypes.func,
}

export default BooksYear
