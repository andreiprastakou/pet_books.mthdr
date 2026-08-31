import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import AuthorsList from 'panels/authorsList/AuthorsList'
import AuthorCard from 'panels/authorCard/AuthorCard'
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
            header='Selected Author'
            showPicture={false}
          />
        </div>
      </Col>
    </Layout>
  </>
)

export default AuthorsPage
