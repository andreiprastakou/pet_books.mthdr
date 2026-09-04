import React, { useContext } from 'react'
import { Col } from 'react-bootstrap'
import { useSelector } from 'react-redux'

import InternalLink from 'components/InternalLink'
import Layout from 'pages/Layout'
import BooksListCovers from 'panels/BooksListCovers'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageConfigurer from 'pages/tagPage/PageConfigurer'
import { selectCurrentTagIndexEntry } from 'store/tags/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const TagPage = () => {
  const tag = useSelector(selectCurrentTagIndexEntry())
  const { routes: { tagsPagePath }, routesReady } = useContext(UrlStoreContext)

  return (
    <>
      <PageConfigurer />

      <Layout classes='panels-page tag-page'>
        <Col xs={8}>
          <BooksListCovers
            header={routesReady ? (
              <>
                <InternalLink href={tagsPagePath()}>
                  { 'Tags' }
                </InternalLink>

                { '/' }
                &nbsp;

                <span title={tag?.name}>
                  { `#${tag?.name || ''}` }
                </span>
              </>
            ) : null}
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
