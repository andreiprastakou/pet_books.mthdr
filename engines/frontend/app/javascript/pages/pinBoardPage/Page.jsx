import React from 'react'
import { Card } from 'react-bootstrap'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageConfigurer from 'pages/pinBoardPage/PageConfigurer'
import PinBoardLists from 'pages/pinBoardPage/PinBoardLists'

const PinBoardTitle = () => (
  <Card
    aria-label='Pin board'
    className='panel--pin-board panel--widget'
    role='region'
  >
    <Card.Header className='panel--header'>
      <span>
        { 'Pin board' }
      </span>
    </Card.Header>
  </Card>
)

const PinBoardPage = () => (
  <>
    <PageConfigurer />

    <PageFrame className='pin-board-page'>
      <Column span={3}>
        <Slot grow={0}>
          <PinBoardTitle />
        </Slot>

        <Slot>
          <PinBoardLists />
        </Slot>
      </Column>
    </PageFrame>
  </>
)

export default PinBoardPage
