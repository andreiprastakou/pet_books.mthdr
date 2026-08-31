import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorsList from 'panels/authorsList/AuthorsList'
import AuthorCard from 'panels/authorCard/AuthorCard'
import PageConfigurer from 'pages/authorsPage/PageConfigurer'

const AuthorsPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page authors-list-page'>
      <Col xs={8}>
        <AuthorsList />
      </Col>

      <Col xs={4}>
        <AuthorCard
          header='Selected Author'
          showPicture={false}
        />
      </Col>
    </Layout>
  </>
)

export default AuthorsPage
