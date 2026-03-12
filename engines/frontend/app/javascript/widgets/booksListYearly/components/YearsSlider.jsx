import React, { useCallback, useEffect, useState } from 'react'
import { Slider } from 'rsuite'
import 'rsuite/Slider/styles/index.css'
import { useDispatch, useSelector } from 'react-redux'

import { jumpToYear } from 'widgets/booksListYearly/actions'
import { selectCurrentYear, selectYears } from 'widgets/booksListYearly/selectors'

const YearsSlider = () => {
  const [state, setState] = useState({ value: 0 })
  const dispatch = useDispatch()
  const years = useSelector(selectYears())
  const currentYear = useSelector(selectCurrentYear())

  useEffect(() => currentYear && setState({ value: years.indexOf(currentYear) }), [currentYear])

  const handleChange = useCallback(v => setState({ value: v }), [])
  const handleChangeCommitted = useCallback(i => dispatch(jumpToYear(years[i])), [dispatch, years])

  return (
    <div className='years-slider'>
      <Slider
        handleClassName='slider-handle'
        handleTitle={years[state.value]}
        max={years.length - 1}
        min={0}
        onChange={handleChange}
        onChangeCommitted={handleChangeCommitted}
        tooltip={false}
        value={state.value}
        vertical
      />
    </div>
  )
}

export default YearsSlider
