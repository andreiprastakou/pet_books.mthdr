import React from 'react'
import { useSelector } from 'react-redux'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import AuthorCard from 'panels/authorCard/AuthorCard'
import BooksStack from 'panels/booksStack/BooksStack'
import CollectionWorks from 'panels/CollectionWorks'
import SelectedWork from 'panels/SelectedWork'
import PageStoreConfigurer from 'pages/authorPage/PageStoreConfigurer'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import { selectAuthorFull } from 'store/authors/selectors'

const WorksColumn = () => (
  <Column span={2}>
    <Slot>
      <SelectedWork header='Selected Work' />
    </Slot>

    <Slot>
      <CollectionWorks />
    </Slot>
  </Column>
)

const AuthorPage = () => {
  const authorId = useSelector(selectCurrentAuthorId())
  const authorFull = useSelector(selectAuthorFull(authorId))
  const description = authorFull?.description

  return (
    <>
      <PageStoreConfigurer />

      { description ? (
        <PageFrame className='page--author page--author-with-description'>
          <Column span={3}>
            <Slot
              grow={0}
              maxHeight='30%'
              minHeight='220px'
            >
              <AuthorCard
                linkToAuthorPage={false}
                showDescription
              />
            </Slot>

            <Slot>
              <div className='author-page-rest'>
                <Column span={1}>
                  <Slot>
                    <BooksStack />
                  </Slot>
                </Column>

                <WorksColumn />
              </div>
            </Slot>
          </Column>
        </PageFrame>
      ) : (
        <PageFrame className='page--author'>
          <Column span={1}>
            <Slot
              grow={0}
              maxHeight='45%'
              minHeight='220px'
            >
              <AuthorCard linkToAuthorPage={false} />
            </Slot>

            <Slot>
              <BooksStack />
            </Slot>
          </Column>

          <WorksColumn />
        </PageFrame>
      ) }
    </>
  )
}

export default AuthorPage
