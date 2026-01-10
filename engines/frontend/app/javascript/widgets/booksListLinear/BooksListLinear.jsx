import React from 'react'
import { useSelector } from 'react-redux'

import { selectBookIds } from 'widgets/booksListLinear/selectors'

import BooksRow from 'widgets/booksListLinear/components/BooksRow'
import HotKeysWrap from 'widgets/booksListLinear/components/HotKeysWrap'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'
import WidgetConfigurer from 'widgets/booksListLinear/WidgetConfigurer'

const buildBookRowConfigs = bookIds => {
  const rowLength = 4
  const rowsCount = Math.ceil(bookIds.length / rowLength)
  return [...Array(rowsCount).keys()].map(i => bookIds.slice(rowLength * i, rowLength * (i + 1)))
}

const BooksListLinear = () => {
  const bookIds = useSelector(selectBookIds())
  const rows = buildBookRowConfigs(bookIds)

  return (
    <>
      <LocalUrlStoreConfigurer />

      <WidgetConfigurer />

      <HotKeysWrap>
        <div className='books-list-linear'>
          <div className='books-list-shadow shadow-top' />

          <div className='books-list-shadow shadow-bottom' />

          <div className='books-list-shadow shadow-left' />

          <div className='books-list-shadow shadow-right' />

          <div className='books-list-layer2'>
            <div className='books-list-layer3'>
              { rows.map(booksRowIds =>
                (<BooksRow
                  ids={booksRowIds}
                  key={booksRowIds.join('-')}
                 />)
              ) }
            </div>
          </div>
        </div>
      </HotKeysWrap>
    </>
  )
}

export default BooksListLinear
