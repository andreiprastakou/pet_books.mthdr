import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import CollectionWorks from 'panels/CollectionWorks'
import SelectedWork from 'panels/SelectedWork'
import PageConfigurer from 'pages/bookPage/PageConfigurer'

const BookPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='page--book'>
      <Column span={3}>
        <Slot>
          <SelectedWork />
        </Slot>

        <Slot>
          <CollectionWorks />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default BookPage
