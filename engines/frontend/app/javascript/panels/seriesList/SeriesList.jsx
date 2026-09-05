import sortBy from 'lodash/sortBy'
import upperCase from 'lodash/upperCase'
import React, { useCallback, useContext, useMemo, useState } from 'react'
import { Card, Form } from 'react-bootstrap'
import { shallowEqual, useSelector } from 'react-redux'

import InternalLink from 'components/InternalLink'
import { selectSeriesIndexList } from 'store/series/selectors'
import UrlStoreContext from 'store/urlStore/Context'

const SeriesList = () => {
  const seriesList = useSelector(selectSeriesIndexList(), shallowEqual)
  const { routes: { seriesPagePath }, routesReady } = useContext(UrlStoreContext)
  const [nameFilter, setNameFilter] = useState('')

  const handleNameFilterChange = useCallback(event => setNameFilter(event.target.value), [])

  const filteredSeries = useMemo(() => {
    const normalizedNameFilter = nameFilter.trim().toUpperCase()
    const filtered = seriesList.filter(entry =>
      !normalizedNameFilter || upperCase(entry.name).includes(normalizedNameFilter)
    )
    return sortBy(filtered, entry => upperCase(entry.name))
  }, [nameFilter, seriesList])

  return (
    <Card
      aria-label='Series'
      className='panel--series-list panel--widget'
    >
      <Card.Header className='panel--header'>
        <span>
          { 'All Series' }
        </span>

        <span className='series-list-count-badge'>
          { filteredSeries.length }
        </span>

        <Form.Control
          aria-label='Filter series by name'
          className='series-list-name-filter'
          onChange={handleNameFilterChange}
          placeholder='Filter by name'
          type='search'
          value={nameFilter}
        />
      </Card.Header>

      <Card.Body className='panel--body'>
        <div className='series-index-entries'>
          { routesReady ? filteredSeries.map(entry => (
            <div
              className='series-index-entry'
              key={entry.id}
            >
              <InternalLink href={seriesPagePath(entry.id)}>
                { entry.name }
              </InternalLink>
            </div>
          )) : null }
        </div>
      </Card.Body>
    </Card>
  )
}

export default SeriesList
