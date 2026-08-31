import React from 'react'
import { useSelector } from 'react-redux'
import { Col } from 'react-bootstrap'

import Layout from 'pages/Layout'
import PageConfigurer from 'pages/tagsPage/PageConfigurer'
import TagsList from 'panels/tagsList/TagsList'
import TagCard from 'sidebar/tagCard/TagCard'
import { selectCurrentTagId } from 'store/axis/selectors'

const TagsPage = () => {
  const sidebarShown = Boolean(useSelector(selectCurrentTagId()))
  return (
    <>
      <PageConfigurer />

      <Layout classes='tags-page'>
        { sidebarShown ? (
          <Col xs={4}>
            <div className='page-sidebar'>
              <TagCard />
            </div>
          </Col>
        ) : null }

        <Col xs={sidebarShown ? 8 : 12}>
          <TagsList />
        </Col>
      </Layout>
    </>
  )
}

export default TagsPage
