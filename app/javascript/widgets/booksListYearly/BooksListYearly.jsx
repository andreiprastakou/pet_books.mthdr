import React from 'react'
import { useSelector } from 'react-redux'

import { selectYearsToDisplay } from 'widgets/booksListYearly/selectors'

import HotKeysWrap from 'widgets/booksListYearly/components/HotKeysWrap'
import YearRow from 'widgets/booksListYearly/components/YearRow'
import YearsSlider from 'widgets/booksListYearly/components/YearsSlider'

const BooksListYearly = () => {
  const yearsToDisplay = useSelector(selectYearsToDisplay())

  return (
    <HotKeysWrap>
      <div className='books-list'>
        <div className='books-list-shadow shadow-top' />

        <div className='books-list-shadow shadow-bottom' />

        <div className='books-list-shadow shadow-left' />

        <div className='books-list-shadow shadow-right' />

        <div className='side-scroll'>
          <YearsSlider />
        </div>

        <div className='books-list-layer2'>
          <div className='books-list-layer3'>
            { yearsToDisplay.map(year =>
              (<YearRow
                key={year}
                year={year}
               />)
            ) }
          </div>
        </div>
      </div>
    </HotKeysWrap>
  )
}

export default BooksListYearly
