import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageConfigurer from 'pages/seriesIndexPage/PageConfigurer'
import SeriesList from 'panels/seriesList/SeriesList'

const SeriesIndexPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='page--series-index'>
      <Column span={3}>
        <Slot>
          <SeriesList />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default SeriesIndexPage
