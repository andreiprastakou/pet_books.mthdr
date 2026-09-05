import React from 'react'
import { Col } from 'react-bootstrap'
import { useSelector } from 'react-redux'

import Layout from 'pages/Layout'
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

      <Layout classes='panels-page series-page'>
        <Col xs={8}>
          <SeriesIntro series={series} />

          <BooksListCovers
            header='Books'
            showControls={false}
          />
        </Col>

        <Col xs={4}>
          <div className='panel--selected-book--narrow'>
            <BookDetails
              header='Selected Book'
              showCover={false}
            />
          </div>
        </Col>
      </Layout>
    </>
  )
}

export default SeriesPage
