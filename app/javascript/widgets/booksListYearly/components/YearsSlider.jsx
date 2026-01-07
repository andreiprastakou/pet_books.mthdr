import React, { useEffect, useState } from 'react'
import { Slider } from 'rsuite'
import { useDispatch, useSelector } from 'react-redux'

import { selectCurrentYear, selectYears } from 'widgets/booksListYearly/selectors'
import { jumpToYear } from 'widgets/booksListYearly/actions'

const YearsSlider = (props) => {
  const [state, setState] = useState({ value: 0 })
  const years = useSelector(selectYears())
  const currentYear = useSelector(selectCurrentYear())
  const dispatch = useDispatch()

  useEffect(() => currentYear && setState({ value: years.indexOf(currentYear) }), [currentYear])

  return (
    <div className='years-slider'>
      <Slider
        value={ state.value }
        min={ 0 }
        max={ years.length - 1 }
        handleClassName='slider-handle'
        handleTitle={ years[state.value] }
        tooltip={ false }
        vertical
        onChange={ (v) => setState({ value: v }) }
        // onChangeCommitted={ (i) => dispatch(jumpToYear(years[i])) }
      />
    </div>
  )
}

export default YearsSlider
