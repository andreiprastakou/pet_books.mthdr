import React from 'react'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import TagCard from 'sidebar/tagCard/TagCard'
import BookCard from 'sidebar/bookCard/BookCard'
import BooksListLinearControls from 'sidebar/booksListLinearControls/BooksListLinearControls'
import BooksListLinear from 'widgets/booksListLinear/BooksListLinear'
import PageConfigurer from 'pages/tagPage/PageConfigurer'

const TagPage = () => (
  <>
    <PageConfigurer />

    <Layout>
      <Col xs={4}>
        <div className='page-sidebar'>
          <BookCard />

          <TagCard />

          <BooksListLinearControls />
        </div>
      </Col>

      <Col xs={8}>
        <BooksListLinear />
      </Col>
    </Layout>
  </>
)

export default TagPage
