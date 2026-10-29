import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageConfigurer from 'pages/bookPage/PageConfigurer'

const BookPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='page--book'>
      <Column span={3}>
        <Slot>
          <BookDetails />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default BookPage
