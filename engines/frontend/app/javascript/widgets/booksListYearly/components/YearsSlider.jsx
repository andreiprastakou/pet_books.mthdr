import React, { useCallback, useEffect, useState } from 'react'
import { Slider } from 'rsuite'
import { useSelector } from 'react-redux'

import { selectCurrentYear, selectYears } from 'widgets/booksListYearly/selectors'

const YearsSlider = () => {
  const [state, setState] = useState({ value: 0 })
  const years = useSelector(selectYears())
  const currentYear = useSelector(selectCurrentYear())

  useEffect(() => currentYear && setState({ value: years.indexOf(currentYear) }), [currentYear])

  const handleChange = useCallback(v => setState({ value: v }), [])

  return (
    <div className='years-slider'>
      <Slider
        handleClassName='slider-handle'
        handleTitle={years[state.value]}
        max={years.length - 1}
        min={0}
        onChange={handleChange}
        tooltip={false}
        value={state.value}
        vertical
        // onChangeCommitted={ (i) => dispatch(jumpToYear(years[i])) }
      />
    </div>
  )
}

export default YearsSlider
