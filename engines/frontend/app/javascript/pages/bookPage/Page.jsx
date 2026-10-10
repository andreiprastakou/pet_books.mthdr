import React from 'react'
import { Col } from 'react-bootstrap'

import CollectionWorks from 'panels/CollectionWorks'
import SelectedWork from 'panels/SelectedWork'
import Layout from 'pages/Layout'
import PageConfigurer from 'pages/bookPage/PageConfigurer'

const BookPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page page--book'>
      <Col xs={12}>
        <SelectedWork />

        <CollectionWorks />
      </Col>
    </Layout>
  </>
)

export default BookPage
