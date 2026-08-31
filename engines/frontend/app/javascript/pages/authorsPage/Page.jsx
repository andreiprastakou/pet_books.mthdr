import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorsList from 'pages/authorsPage/components/AuthorsList'
import AuthorCard from 'sidebar/authorCard/AuthorCard'
import PageConfigurer from 'pages/authorsPage/PageConfigurer'

const AuthorsPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='authors-list-page'>
      <Col xs={8}>
        <div className='page-sidebar'>
          <AuthorsList />
        </div>
      </Col>

      <Col xs={4}>
        <div className='authors-selected-author'>
          <AuthorCard
            showPicture={false}
            title='Selected Author'
          />
        </div>
      </Col>
    </Layout>
  </>
)

export default AuthorsPage
