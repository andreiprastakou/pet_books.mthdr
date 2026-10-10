import React from 'react'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import AuthorsList from 'panels/authorsList/AuthorsList'
import AuthorCard from 'panels/authorCard/AuthorCard'
import PageConfigurer from 'pages/authorsPage/PageConfigurer'

const AuthorsPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='authors-list-page'>
      <Column span={2}>
        <Slot>
          <AuthorsList />
        </Slot>
      </Column>

      <Column span={1}>
        <Slot>
          <AuthorCard
            header='Selected Author'
            showPicture={false}
          />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default AuthorsPage
