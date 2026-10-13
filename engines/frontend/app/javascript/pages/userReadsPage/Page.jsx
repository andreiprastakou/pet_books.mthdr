import React from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageLoading from 'components/pageFrame/PageLoading'
import BooksListCovers, { READS_SORT_OPTIONS } from 'panels/BooksListCovers'
import BookDetails from 'panels/bookDetails/BookDetails'

const UserReadsPage = ({ status }) => {
  if (status === 'missing') return <MissingSharedReads />
  if (status !== 'ready') return <PageLoading />

  return (
    <PageFrame className='user-reads-page'>
      <Column span={2}>
        <Slot>
          <BooksListCovers
            header='shared reads'
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
  )
}

UserReadsPage.propTypes = {
  status: PropTypes.oneOf(['loading', 'ready', 'missing']).isRequired,
}

const MissingSharedReads = () => (
  <PageFrame className='user-reads-page'>
    <Column span={3}>
      <Slot>
        <Card className='panel--widget'>
          <Card.Header className='panel--header'>
            { 'shared reads' }
          </Card.Header>

          <Card.Body>
            { 'This shared reads link is not valid.' }
          </Card.Body>
        </Card>
      </Slot>
    </Column>
  </PageFrame>
)

export default UserReadsPage
