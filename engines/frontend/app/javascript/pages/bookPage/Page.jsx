import React from 'react'
import { Col } from 'react-bootstrap'

import BookDetails from 'panels/bookDetails/BookDetails'
import IncludedWorks from 'panels/IncludedWorks'
import Layout from 'pages/Layout'
import PageConfigurer from 'pages/bookPage/PageConfigurer'

const BookPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page page--book'>
      <Col xs={12}>
        <BookDetails />

        <IncludedWorks />
      </Col>
    </Layout>
  </>
)

export default BookPage
