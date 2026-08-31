import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import AllBooksList from 'panels/allBooksList/AllBooksList'
import PageConfigurer from 'pages/booksPage/PageConfigurer'

const BooksPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='all-books-page'>
      <Col xs={8}>
        <div className='page-sidebar'>
          <AllBooksList />
        </div>
      </Col>

      <Col xs={4}>
        <div className='all-books-selected-book'>
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
