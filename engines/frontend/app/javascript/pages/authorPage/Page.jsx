import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorCard from 'panels/authorCard/AuthorCard'
import BooksStack from 'panels/booksStack/BooksStack'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageStoreConfigurer from 'pages/authorPage/PageStoreConfigurer'
import LocalUrlStoreConfigurer from 'widgets/booksListLinear/UrlStore'

const AuthorPage = () => (
  <>
    <LocalUrlStoreConfigurer />

    <PageStoreConfigurer />

    <Layout>
      <Col xs={4}>
        <div className='page-sidebar'>
          <AuthorCard linkToAuthorPage={false} />

          <BooksStack />
        </div>
      </Col>

      <Col xs={8}>
        <BookDetails header='Selected Work' />
      </Col>
    </Layout>
  </>
)

export default AuthorPage
