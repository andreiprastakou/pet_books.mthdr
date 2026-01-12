import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import { selectBookPopularities } from 'store/books/selectors'
import PopularityChart from 'components/PopularityChart'

const BOOK_CASE_WIDTH = 180
const BOOKS_SEPARATOR_WIDTH = 20

const widthOfPopularityChart = length => length * (BOOK_CASE_WIDTH + BOOKS_SEPARATOR_WIDTH) - BOOK_CASE_WIDTH + 60

const mapPopularityChart = bookPopularities => bookPopularities.map((popularity, i) =>
  ({
    x: i * (BOOK_CASE_WIDTH + BOOKS_SEPARATOR_WIDTH),
    y: popularity
  })
)

const Component = ({ bookIds }) => {
  const popularities = useSelector(selectBookPopularities(bookIds))

  if (bookIds.length < 2)  return null
  return (
    <PopularityChart
      points={mapPopularityChart(popularities)}
      width={widthOfPopularityChart(bookIds.length)}
    />
  )
}

Component.propTypes = {
  bookIds: PropTypes.array.isRequired,
}

export default Component
