import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import PageConfigurer from 'pages/tagsPage/PageConfigurer'
import TagsList from 'panels/tagsList/TagsList'

const TagsPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page page--tags'>
      <Col xs={12}>
        <TagsList />
      </Col>
    </Layout>
  </>
)

export default TagsPage
