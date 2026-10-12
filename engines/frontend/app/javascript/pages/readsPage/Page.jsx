import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import BooksListCovers, { READS_SORT_OPTIONS } from 'panels/BooksListCovers'
import BookDetails from 'panels/bookDetails/BookDetails'
import PageConfigurer from 'pages/readsPage/PageConfigurer'
import ShareReadsButton from 'pages/readsPage/ShareReadsButton'

const ReadsPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='reads-page'>
      <Column span={2}>
        <Slot>
          <BooksListCovers
            header='YOUR READS'
            headerAction={<ShareReadsButton />}
            sortOptions={READS_SORT_OPTIONS}
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

export default ReadsPage
