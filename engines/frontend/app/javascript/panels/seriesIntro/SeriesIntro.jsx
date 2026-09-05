import React, { useContext } from 'react'
import { ButtonGroup, Card } from 'react-bootstrap'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'
import InternalLink from 'components/InternalLink'
import UrlStoreContext from 'store/urlStore/Context'

const SeriesIntro = ({ series }) => {
  const { routes: { seriesIndexPagePath }, routesReady } = useContext(UrlStoreContext)

  if (!series || !routesReady) return null

  const links = [
    ...(series.wikiUrl ? [{ name: 'wikipedia', url: series.wikiUrl }] : []),
    ...(series.genericLinks || []),
  ]

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

      { links.length > 0 ? (
        <Card.Body className='panel--body'>
          <ButtonGroup>
            { links.map(link => (
              <ExternalTextLink
                href={link.url}
                key={link.url}
                resource={link.name}
              />
            )) }
          </ButtonGroup>
        </Card.Body>
      ) : null }
    </Card>
  )
}

SeriesIntro.propTypes = {
  series: PropTypes.object,
}

export default SeriesIntro
