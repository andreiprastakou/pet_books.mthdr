import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import PageConfigurer from 'pages/seriesIndexPage/PageConfigurer'
import SeriesList from 'panels/seriesList/SeriesList'

const SeriesIndexPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page page--series-index'>
      <Col xs={12}>
        <SeriesList />
      </Col>
    </Layout>
  </>
)

export default SeriesIndexPage
