import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksYear from 'panels/booksYear/BooksYear'
import PageConfigurer from 'pages/booksPage/PageConfigurer'

const BooksPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page page--books'>
      <Col xs={8}>
        <BooksYear />
      </Col>

      <Col xs={4}>
        <div className='panel--selected-book--narrow'>
          <BookDetails
            header='Selected book'
            showCover={false}
          />
        </div>
      </Col>
    </Layout>
  </>
)

export default BooksPage
