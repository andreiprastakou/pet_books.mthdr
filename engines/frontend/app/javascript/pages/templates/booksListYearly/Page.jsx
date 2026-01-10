import React from 'react'
import PropTypes from 'prop-types'
import { Col } from 'react-bootstrap'

import PageConfigurer from 'pages/templates/booksListYearly/PageConfigurer'
import Layout from 'pages/Layout'
import BooksListYearly from 'widgets/booksListYearly/BooksListYearly'
import ListUrlStoreConfigurer from 'widgets/booksListYearly/UrlStore'

const Page = props => {
  const { config } = props
  return (
    <>
      <ListUrlStoreConfigurer />

      <PageConfigurer listFilter={config.booksListFilter} />

      <Layout>
        <Col xs={4}>
          <div className='page-sidebar'>
            { config.SidebarCardWidget ? <config.SidebarCardWidget /> : null}
          </div>
        </Col>

        <Col xs={8}>
          <BooksListYearly />
        </Col>
      </Layout>
    </>
  )
}

Page.propTypes = {
  config: PropTypes.object.isRequired,
}

export default Page
