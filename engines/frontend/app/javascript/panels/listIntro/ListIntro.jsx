import React, { useCallback } from 'react'
import { ButtonGroup, Card, Form } from 'react-bootstrap'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'

const PublicListIntro = ({ listType, selectedYear, setSelectedYear }) => {
  const publicLists = listType.public_lists || []
  const typeLinks = [
    ...(listType.wiki_url ? [{ name: 'wikipedia', url: listType.wiki_url }] : []),
    ...(listType.generic_links || []),
  ]
  const selectedList = listType.public_lists.find(list => list.year === selectedYear)
  const listLinks = selectedList?.generic_links || []
  const handleYearChange = useCallback(event => {
    setSelectedYear(parseInt(event.target.value))
  }, [setSelectedYear])

  return (
    <Card className='panel--public-list-intro panel--widget'>
      <Card.Header className='panel--header'>
        <span>
          { `Public lists/ ${listType.name}` }
        </span>

        { selectedYear === null ? null : (
          <Form.Select
            aria-label='List year'
            onChange={handleYearChange}
            value={selectedYear}
          >
            { publicLists.map(list => (
              <option
                key={list.year}
                value={list.year}
              >
                { list.year }
              </option>
            )) }
          </Form.Select>
        ) }
      </Card.Header>

      <Card.Body className='panel--body'>
        <ButtonGroup>
          { typeLinks.map(link => (
            <ExternalTextLink
              href={link.url}
              key={link.url}
              text={link.name}
            />
          )) }
        </ButtonGroup>

        { listLinks.length > 0 ? (
          <div className='public-list-intro-list-links'>
            <ButtonGroup>
              { listLinks.map(link => (
                <ExternalTextLink
                  href={link.url}
                  key={link.url}
                  text={`${selectedYear} ${link.name}`}
                />
              )) }
            </ButtonGroup>
          </div>
        ) : null }
      </Card.Body>
    </Card>
  )
}

PublicListIntro.propTypes = {
  listType: PropTypes.object.isRequired,
  selectedYear: PropTypes.number,
  setSelectedYear: PropTypes.func.isRequired,
}

export default PublicListIntro
