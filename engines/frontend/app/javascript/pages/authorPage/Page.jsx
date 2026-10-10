import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import AuthorCard from 'panels/authorCard/AuthorCard'
import BooksStack from 'panels/booksStack/BooksStack'
import CollectionWorks from 'panels/CollectionWorks'
import SelectedWork from 'panels/SelectedWork'
import PageStoreConfigurer from 'pages/authorPage/PageStoreConfigurer'

const AuthorPage = () => (
  <>
    <PageStoreConfigurer />

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

      <Column span={2}>
        <Slot>
          <SelectedWork header='Selected Work' />
        </Slot>

        <Slot>
          <CollectionWorks />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default AuthorPage
