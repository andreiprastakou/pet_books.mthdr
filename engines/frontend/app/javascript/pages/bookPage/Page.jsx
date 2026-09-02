import React from 'react'
import { Col } from 'react-bootstrap'

import BookDetails from 'panels/bookDetails/BookDetails'
import Layout from 'pages/Layout'

const BookPage = () => (
  <Layout classes='panels-page page--book'>
    <Col xs={12}>
      <BookDetails />
    </Col>
  </Layout>
)

export default BookPage
