import React from 'react'
import { useSelector } from 'react-redux'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import BooksListCovers from 'panels/BooksListCovers'
import BookDetails from 'panels/bookDetails/BookDetails'
import SeriesIntro from 'panels/seriesIntro/SeriesIntro'
import PageConfigurer from 'pages/seriesPage/PageConfigurer'
import { selectCurrentSeriesIndexEntry } from 'store/series/selectors'

const SeriesPage = () => {
  const series = useSelector(selectCurrentSeriesIndexEntry())

  return (
    <>
      <PageConfigurer />

      <PageFrame className='series-page'>
        <Column span={2}>
          <Slot grow={0}>
            <SeriesIntro series={series} />
          </Slot>

          <Slot>
            <BooksListCovers
              header='Books'
              showControls={false}
            />
          </Slot>
        </Column>

        <Column span={1}>
          <Slot>
            <BookDetails
              header='Selected Book'
              showCover={false}
            />
          </Slot>
        </Column>
      </PageFrame>
    </>
  )
}

export default SeriesPage
