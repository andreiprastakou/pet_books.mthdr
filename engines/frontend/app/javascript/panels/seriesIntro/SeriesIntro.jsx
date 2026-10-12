import React, { useCallback, useContext } from 'react'
import { useDispatch } from 'react-redux'
import { ButtonGroup, Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import PinButton from 'components/PinButton'
import { saveSeriesPin } from 'store/series/actions'
import UrlStoreContext from 'store/urlStore/Context'

const SeriesIntro = ({ series }) => {
  const dispatch = useDispatch()
  const { routes: { seriesIndexPagePath }, routesReady } = useContext(UrlStoreContext)
  const savePin = useCallback(
    nextPinned => dispatch(saveSeriesPin(series && series.id, nextPinned)),
    [dispatch, series]
  )

  if (!series || !routesReady) return null

  const links = series.externalLinks || []

  return (
    <Card className='panel--series-intro panel--widget'>
      <Card.Header className='panel--header'>
        <span>
          <InternalLink href={seriesIndexPagePath()}>
            { 'Series' }
          </InternalLink>

          { '/' }
          &nbsp;

          <span title={series.name}>
            { series.name }
          </span>
        </span>
      </Card.Header>

      <Card.Body className='panel--body'>
        <ButtonGroup>
          <PinButton
            onChange={savePin}
            pinned={Boolean(series.pinned)}
          />

          { links.map(link => (
            <ExternalTextLink
              href={link.url}
              key={link.url}
              label={link.label}
            />
          )) }
        </ButtonGroup>
      </Card.Body>
    </Card>
  )
}

SeriesIntro.propTypes = {
  series: PropTypes.object,
}

export default SeriesIntro
