import React from 'react'
import PropTypes from 'prop-types'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import useCompactLayout from 'hooks/useCompactLayout'
import AuthorsList from 'panels/authorsList/AuthorsList'
import AuthorCard from 'panels/authorCard/AuthorCard'
import PageConfigurer from 'pages/authorsPage/PageConfigurer'

const SelectedAuthor = ({ showPicture }) => (
  <Slot>
    <AuthorCard
      header='Selected Author'
      showPicture={showPicture}
    />
  </Slot>
)

SelectedAuthor.propTypes = {
  showPicture: PropTypes.bool.isRequired,
}

const AuthorsPage = () => {
  const compact = useCompactLayout()

  return (
    <>
      <PageConfigurer />

      <PageFrame className='authors-list-page'>
        <Column span={compact ? 3 : 2}>
          <Slot>
            <AuthorsList />
          </Slot>

          { compact ? <SelectedAuthor showPicture /> : null }
        </Column>

        { compact ? null : (
          <Column span={1}>
            <SelectedAuthor showPicture={false} />
          </Column>
        ) }
      </PageFrame>
    </>
  )
}

export default AuthorsPage
