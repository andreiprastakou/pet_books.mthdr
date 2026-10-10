import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageConfigurer from 'pages/tagsPage/PageConfigurer'
import TagsList from 'panels/tagsList/TagsList'

const TagsPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='page--tags'>
      <Column span={3}>
        <Slot>
          <TagsList />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default TagsPage
