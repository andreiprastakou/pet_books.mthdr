import React, { useCallback } from 'react'
import PropTypes from 'prop-types'
import { useDispatch, useSelector } from 'react-redux'
import classnames from 'classnames'

import { selectCurrentBookRef } from 'store/books/selectors'
import {
  selectBookShiftDirectionHorizontal,
  selectDisplayedBookIdsInYear,
} from 'widgets/booksListYearly/selectors'
import {
  setBookShiftDirectionHorizontal,
} from 'widgets/booksListYearly/actions'

import PopularityChart from 'widgets/booksListYearly/components/PopularityChart'
import BookIndexEntry from 'widgets/booksListYearly/components/BookIndexEntry'
import ImageContainer from 'components/ImageContainer'

const YEAR_BACKGROUNDS = {}

const YearRow = props => {
  const { year } = props
  const currentBookRef = useSelector(selectCurrentBookRef())
  const displayedBookIds = useSelector(selectDisplayedBookIdsInYear(year))
  const yearIsCurrent = year === currentBookRef.year
  const direction = useSelector(selectBookShiftDirectionHorizontal())
  const dispatch = useDispatch()

  const onAnimationEnd = useCallback(e => {
    if (e.animationName === 'move-left' || e.animationName === 'move-right')
      dispatch(setBookShiftDirectionHorizontal(null))
  }, [])

  const yearBackgroundUrl = YEAR_BACKGROUNDS[year]

  return (
    <div className={classnames('list-year', { 'current': yearIsCurrent })}>
      { yearIsCurrent && yearBackgroundUrl ? (
        <ImageContainer
          className='background'
          styles={{ backgroundSize: 'cover' }}
          url={yearBackgroundUrl}
        />
      ) : null}

      { yearIsCurrent ? <PopularityChart bookIds={displayedBookIds} /> : null}

      <div className='b-bookself-top-desk'></div>

      <div className='b-bookself-bottom-desk'>
        <div className='year-number'>
          { year }
        </div>
      </div>

      <div
        className={
          classnames('year-books', {
            'shifted-left': yearIsCurrent && direction === 'right',
            'shifted-right': yearIsCurrent && direction === 'left',
          })
        }
        onAnimationEnd={onAnimationEnd}
      >
        { displayedBookIds.map(bookId =>
          (<BookIndexEntry
            id={bookId}
            key={[bookId, direction].join()}
           />)
        ) }
      </div>
    </div>
  )
}

YearRow.propTypes = {
  year: PropTypes.number.isRequired,
}

export default YearRow
