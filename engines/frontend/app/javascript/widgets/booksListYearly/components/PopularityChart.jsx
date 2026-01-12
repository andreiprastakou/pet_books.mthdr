import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectBookPopularities } from 'store/books/selectors'
import PopularityChart from 'components/PopularityChart'

const BOOK_CASE_WIDTH = 180
const BOOK_VIEW_WIDTH = 300
const BOOKS_SEPARATOR_WIDTH = 20

const widthOfPopularityChart = length =>
  (length - 1) * (BOOK_CASE_WIDTH + BOOKS_SEPARATOR_WIDTH) + BOOK_VIEW_WIDTH - BOOK_CASE_WIDTH + 60

const mapPopularityChart = (bookPopularities, currentIndex) => bookPopularities.map((popularity, i) =>
  ({
    x: i * (BOOK_CASE_WIDTH + BOOKS_SEPARATOR_WIDTH) + (i > currentIndex ? 160 : 0),
    y: popularity
  })
)

const Component = props => {
  const { bookIds } = props
  const currentId = useSelector(selectCurrentBookId())
  const popularities = useSelector(selectBookPopularities(bookIds))

  if (bookIds.length < 2)  return null
  return (
    <PopularityChart
      points={mapPopularityChart(popularities, bookIds.indexOf(currentId))}
      width={widthOfPopularityChart(bookIds.length)}
    />
  )
}

Component.propTypes = {
  bookIds: PropTypes.array.isRequired,
}

export default Component
