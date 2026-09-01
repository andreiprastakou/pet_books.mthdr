import React, {
  useCallback, useContext, useEffect, useLayoutEffect, useMemo, useRef, useState,
} from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'
import { useDispatch, useSelector } from 'react-redux'

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
import { selectYears } from 'widgets/booksListYearly/selectors'
import UrlStoreContext from 'store/urlStore/Context'

export const WIDGET_ID = 'books-list-yearly'

const BOOK_WIDTH = 190
const BOOK_HEIGHT = 270
const CELL_WIDTH = 200
const CELL_HEIGHT = 280
const VISIBLE_COLUMN_RADIUS = 2
const VISIBLE_ROW_RADIUS = 1
const defaultTitle = () => 'Books of year'

const spiralPositions = count => {
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

const buildBookMatrix = (bookIds, selectedId) => {
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
  const years = useSelector(selectYears())
  const currentBookId = useSelector(selectCurrentBookId())
  const ref = useRef(null)
  const contentRef = useRef(null)
  const [contentSize, setContentSize] = useState({ height: 0, width: 0 })
  const {
    pageState: { activeWidgetId, registeredWidgetIds },
    actions: {
      activateWidget,
      deactivateWidget,
      registerWidget,
      unregisterWidget,
    },
  } = useContext(UrlStoreContext)
  const selectedYear = filter.years?.[0] || years[years.length - 1]
  const isActive = activeWidgetId === WIDGET_ID
  const hasActivated = useRef(false)
  const matrixRef = useRef({ key: null, bookIds: [] })
  const bookIdsKey = bookIds.join(',')
  if (matrixRef.current.key !== bookIdsKey) {
    const selectedId = bookIds.includes(currentBookId) ? currentBookId : bookIds[0]
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

  const bookPositions = useMemo(() => {
    const positions = spiralPositions(matrixBookIds.length)
    const centerX = contentSize.width / 2
    const centerY = contentSize.height / 2
    return matrixBookIds.reduce((result, bookId, index) => {
      const [column, row] = positions[index]
      result[bookId] = {
        left: centerX + ((column - selectedCoordinate[0]) * CELL_WIDTH) - (BOOK_WIDTH / 2),
        top: centerY + ((row - selectedCoordinate[1]) * CELL_HEIGHT) - (BOOK_HEIGHT / 2),
      }
      return result
    }, {})
  }, [contentSize, matrixBookIds, selectedCoordinate])

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
    registerWidget(WIDGET_ID)

    return () => unregisterWidget(WIDGET_ID)
  }, [])

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

  const selectYear = useCallback(year => {
    dispatch(clearListState())
    dispatch(assignFilter({ years: [year] }))
    dispatch(assignPage(1))
    dispatch(fetchBooks()).then(() => dispatch(switchToFirstBook()))
  }, [dispatch])

  const handleClick = useCallback(event => {
    activateWidget(WIDGET_ID)
    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl)
      ref.current?.focus()
  }, [activateWidget])

  const handleFocus = useCallback(() => activateWidget(WIDGET_ID), [activateWidget])

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

        <div>
          <YearControl
            onChange={selectYear}
            value={selectedYear}
            years={years}
          />
        </div>
      </Card.Header>

      <Card.Body className='all-books-list-body'>
        <div
          className='all-books-list'
          ref={contentRef}
        >
          {visibleBookIds.map(bookId => (
            <BookIndexEntry
              id={bookId}
              key={bookId}
              scrollIntoView={false}
              showYear={false}
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
