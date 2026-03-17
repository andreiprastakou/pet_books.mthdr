import React from 'react'
import { Col } from 'react-bootstrap'

import PageConfigurer from 'pages/templates/booksListYearly/PageConfigurer'
import Layout from 'pages/Layout'
import BooksListYearly from 'widgets/booksListYearly/BooksListYearly'

const BooksPage = () => (
  <>
    <PageConfigurer />

    <Layout>
      <BooksListYearly />
    </Layout>
  </>
)

export default BooksPage
