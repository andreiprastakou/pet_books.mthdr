import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorCard from 'panels/authorCard/AuthorCard'
import BooksStack from 'panels/booksStack/BooksStack'
import CollectionWorks from 'panels/CollectionWorks'
import SelectedWork from 'panels/SelectedWork'
import PageStoreConfigurer from 'pages/authorPage/PageStoreConfigurer'

const AuthorPage = () => (
  <>
    <PageStoreConfigurer />

    <Layout classes='panels-page page--author'>
      <Col xs={4}>
        <AuthorCard linkToAuthorPage={false} />

        <BooksStack />
      </Col>

      <Col xs={8}>
        <SelectedWork header='Selected Work' />

        <CollectionWorks />
      </Col>
    </Layout>
  </>
)

export default AuthorPage
