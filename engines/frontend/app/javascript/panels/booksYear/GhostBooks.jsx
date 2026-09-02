import React, { useMemo } from 'react'
import PropTypes from 'prop-types'

const coordinateRange = radius => Array.from(
  { length: (radius * 2) + 1 },
  (item, index) => index - radius
)

const GhostBooks = ({ cellPosition, centerCoordinate, columnRadius, occupiedKeys, rowRadius }) => {
  const cells = useMemo(() => {
    const positions = coordinateRange(columnRadius).flatMap(columnShift => (
      coordinateRange(rowRadius).map(rowShift => [
        centerCoordinate[0] + columnShift,
        centerCoordinate[1] + rowShift,
      ])
    ))

    return positions
      .map(([column, row]) => ({ key: `${column}:${row}`, style: cellPosition(column, row) }))
      .filter(cell => !occupiedKeys.includes(cell.key))
  }, [cellPosition, centerCoordinate, columnRadius, occupiedKeys, rowRadius])

  return (
    <div
      aria-hidden
      className='all-books-ghosts'
    >
      { cells.map(cell => (
        <div
          className='all-books-ghost'
          key={cell.key}
          style={cell.style}
        >
          <div className='all-books-ghost-cover' />
        </div>
      )) }
    </div>
  )
}

GhostBooks.propTypes = {
  cellPosition: PropTypes.func.isRequired,
  centerCoordinate: PropTypes.array.isRequired,
  columnRadius: PropTypes.number.isRequired,
  occupiedKeys: PropTypes.array.isRequired,
  rowRadius: PropTypes.number.isRequired,
}

export default GhostBooks
