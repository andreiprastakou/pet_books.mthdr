import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorCard from 'sidebar/authorCard/AuthorCard'
import BooksStack from 'sidebar/booksStack/BooksStack'
import SelectedBook from 'widgets/selectedBook/SelectedBook'
import PageStoreConfigurer from 'pages/authorPage/PageStoreConfigurer'

const AuthorPage = () => (
  <>
    <PageStoreConfigurer />

    <Layout>
      <Col xs={4}>
        <div className='page-sidebar'>
          <AuthorCard />

          <BooksStack />
        </div>
      </Col>

      <Col xs={8}>
        <SelectedBook />
      </Col>
    </Layout>
  </>
)

export default AuthorPage
