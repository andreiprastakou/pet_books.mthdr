import React, { useCallback } from 'react'
import { ButtonGroup, Card, Form } from 'react-bootstrap'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'

const PublicListIntro = ({
  listType, selectedListId, setSelectedListId, selectedList,
}) => {
  const publicLists = listType.public_lists || []
  const typeLinks = [
    ...(listType.wiki_url ? [{ name: 'wikipedia', url: listType.wiki_url }] : []),
    ...(listType.generic_links || []),
  ]
  const listLinks = selectedList?.generic_links || []
  const handleListChange = useCallback(event => {
    setSelectedListId(parseInt(event.target.value))
  }, [setSelectedListId])

  return (
    <Card className='panel--public-list-intro panel--widget'>
      <Card.Header className='panel--header'>
        <span>
          { `Public lists/ ${listType.name}` }
        </span>

        { selectedListId === null ? null : (
          <Form.Select
            aria-label='Public list'
            onChange={handleListChange}
            value={selectedListId}
          >
            { publicLists.map(list => (
              <option
                key={list.id}
                value={list.id}
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
              resource={link.name}
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
                  resource={`${selectedList.year} ${link.name}`}
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
  selectedList: PropTypes.object,
  selectedListId: PropTypes.number,
  setSelectedListId: PropTypes.func.isRequired,
}

export default PublicListIntro
