import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksYear from 'panels/booksYear/BooksYear'
import PageConfigurer from 'pages/booksPage/PageConfigurer'

const BooksPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='page--books'>
      <Column span={2}>
        <Slot>
          <BooksYear />
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

export default BooksPage
