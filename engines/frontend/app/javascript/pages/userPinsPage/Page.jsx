import React from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageLoading from 'components/pageFrame/PageLoading'
import { PinBoardFrame } from 'pages/pinBoardPage/Page'

const UserPinsPage = ({ status }) => {
  if (status === 'missing') return <MissingSharedPinBoard />
  if (status !== 'ready') return <PageLoading />

  return <PinBoardFrame />
}

UserPinsPage.propTypes = {
  status: PropTypes.oneOf(['loading', 'ready', 'missing']).isRequired,
}

const MissingSharedPinBoard = () => (
  <PageFrame className='pin-board-page'>
    <Column span={3}>
      <Slot>
        <Card className='panel--widget'>
          <Card.Header className='panel--header'>
            { 'Pin board' }
          </Card.Header>

          <Card.Body>
            { 'This shared pin board link is not valid.' }
          </Card.Body>
        </Card>
      </Slot>
    </Column>
  </PageFrame>
)

export default UserPinsPage
