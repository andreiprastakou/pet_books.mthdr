import React, { useCallback, useEffect, useState } from 'react'
import { Slider } from 'rsuite'
import 'rsuite/Slider/styles/index.css'
import PropTypes from 'prop-types'

const YearControl = ({ years, value, onChange }) => {
  const [inputValue, setInputValue] = useState(value || '')
  const [sliderValue, setSliderValue] = useState(0)
  const valueIndex = Math.max(0, years.indexOf(value))
  const previousYear = years[valueIndex - 1]
  const nextYear = years[valueIndex + 1]

  useEffect(() => setInputValue(value || ''), [value])
  useEffect(() => setSliderValue(valueIndex), [valueIndex])

  const selectYear = useCallback(year => {
    if (years.includes(year)) onChange(year)
  }, [onChange, years])

  const handleInputChange = useCallback(event => {
    setInputValue(event.target.value.replace(/\D/gu, ''))
  }, [])

  const commitInput = useCallback(() => {
    const year = parseInt(inputValue, 10)
    if (years.includes(year))
      onChange(year)
    else
      setInputValue(value || '')
  }, [inputValue, onChange, value, years])

  const handleKeyDown = useCallback(event => {
    if (event.key === 'Enter') event.currentTarget.blur()
  }, [])

  const handleSliderChange = useCallback(index => {
    setSliderValue(index)
  }, [])

  const commitSliderChange = useCallback(index => {
    selectYear(years[index])
  }, [selectYear, years])

  const selectPreviousYear = useCallback(() => onChange(previousYear), [onChange, previousYear])
  const selectNextYear = useCallback(() => onChange(nextYear), [nextYear, onChange])

  if (years.length === 0) return null

  return (
    <div className='all-books-year-control'>
      <input
        aria-label='Selected year'
        className='all-books-year-input'
        inputMode='numeric'
        onBlur={commitInput}
        onChange={handleInputChange}
        onKeyDown={handleKeyDown}
        type='text'
        value={inputValue}
      />

      <span className='all-books-year-buttons'>
        <button
          aria-label='Next available year'
          className='all-books-year-button'
          disabled={valueIndex >= years.length - 1}
          onClick={selectNextYear}
          type='button'
        >
          {'▲'}
        </button>

        <button
          aria-label='Previous available year'
          className='all-books-year-button'
          disabled={valueIndex <= 0}
          onClick={selectPreviousYear}
          type='button'
        >
          {'▼'}
        </button>
      </span>

      <Slider
        className='all-books-years-slider'
        handleTitle={(
          <span className='slider-year-label'>
            { value }
          </span>
        )}
        max={years.length - 1}
        min={0}
        onChange={handleSliderChange}
        onChangeCommitted={commitSliderChange}
        tooltip={false}
        value={sliderValue}
      />
    </div>
  )
}

YearControl.propTypes = {
  onChange: PropTypes.func.isRequired,
  value: PropTypes.number,
  years: PropTypes.arrayOf(PropTypes.number).isRequired,
}

export default YearControl
