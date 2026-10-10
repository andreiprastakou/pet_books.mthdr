import React, { useContext } from 'react'
import { useSelector } from 'react-redux'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import InternalLink from 'components/InternalLink'
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

      <PageFrame className='tag-page'>
        <Column span={2}>
          <Slot>
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
          </Slot>
        </Column>

        <Column span={1}>
          <Slot>
            <BookDetails
              header='Selected book'
              showCover={false}
            />
          </Slot>
        </Column>
      </PageFrame>
    </>
  )
}

export default TagPage
