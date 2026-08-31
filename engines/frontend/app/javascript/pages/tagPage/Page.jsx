import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import TagBooksList from 'panels/tagBooksList/TagBooksList'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageConfigurer from 'pages/tagPage/PageConfigurer'

const TagPage = () => (
  <>
    <PageConfigurer />

    <Layout classes='panels-page tag-page'>
      <Col xs={8}>
        <TagBooksList />
      </Col>

      <Col xs={4}>
        <div className='tag-selected-book'>
          <BookDetails
            header='Selected book'
            showCover={false}
          />
        </div>
      </Col>
    </Layout>
  </>
)

export default TagPage
