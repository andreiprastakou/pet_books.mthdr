import React from 'react'
import { Col } from 'react-bootstrap'
import { useSelector } from 'react-redux'

import Layout from 'pages/Layout'
import BooksListCovers from 'panels/BooksListCovers'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageConfigurer from 'pages/tagPage/PageConfigurer'
import { selectCurrentTagIndexEntry } from 'store/tags/selectors'

const TagPage = () => {
  const tag = useSelector(selectCurrentTagIndexEntry())

  return (
    <>
      <PageConfigurer />

      <Layout classes='panels-page tag-page'>
        <Col xs={8}>
          <BooksListCovers
            header={(
              <>
                <a
                  className='internal-link'
                  href='/tags'
                >
                  { 'Tags' }
                </a>

                { '/' }
                &nbsp;

                <span title={tag?.name}>
                  { `#${tag?.name || ''}` }
                </span>
              </>
            )}
          />
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
}

export default TagPage
