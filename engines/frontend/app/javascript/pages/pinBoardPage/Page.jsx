import React from 'react'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import PageFrame, { Column, Slot } from 'components/pageFrame/PageFrame'
import PageConfigurer from 'pages/pinBoardPage/PageConfigurer'
import PinBoardLists from 'pages/pinBoardPage/PinBoardLists'
import SharePinsButton from 'pages/pinBoardPage/SharePinsButton'

const PinBoardTitle = ({ headerAction = null }) => (
  <Card
    aria-label='Pin board'
    className='panel--pin-board panel--widget'
    role='region'
  >
    <Card.Header className='panel--header'>
      <span>
        { 'Pin board' }
      </span>

      { headerAction }
    </Card.Header>
  </Card>
)

PinBoardTitle.propTypes = {
  headerAction: PropTypes.node,
}

export const PinBoardFrame = ({ headerAction = null }) => (
  <PageFrame className='pin-board-page'>
    <Column span={3}>
      <Slot grow={0}>
        <PinBoardTitle headerAction={headerAction} />
      </Slot>

      <Slot>
        <PinBoardLists />
      </Slot>
    </Column>
  </PageFrame>
)

PinBoardFrame.propTypes = {
  headerAction: PropTypes.node,
}

const PinBoardPage = () => (
  <>
    <PageConfigurer />

    <PinBoardFrame headerAction={<SharePinsButton />} />
  </>
)

export default PinBoardPage
