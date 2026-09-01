import React, { useCallback, useEffect, useState } from 'react'
import { ButtonGroup, Card, Col, Form } from 'react-bootstrap'
import { useParams } from 'react-router-dom'
import PropTypes from 'prop-types'

import ExternalTextLink from 'components/ExternalTextLink'
import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksListCovers from 'panels/BooksListCovers'
import PageConfigurer from 'pages/listsPage/PageConfigurer'
import apiClient from 'store/publicLists/apiClient'

const ListIntro = ({ listType, selectedYear, setSelectedYear }) => {
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
    <Card className='panel--widget list-intro panel--list-intro'>
      <Card.Header className='panel--header'>
        <span>
          { `Lists/ ${listType.name}` }
        </span>

        <Form.Select
          aria-label='List year'
          onChange={handleYearChange}
          value={selectedYear}
        >
          { listType.public_lists.map(list => (
            <option
              key={list.year}
              value={list.year}
            >
              { list.year }
            </option>
          )) }
        </Form.Select>
      </Card.Header>

      <Card.Body>
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
          <div className='list-intro-list-links'>
            <ButtonGroup>
              { listLinks.map(link => (
                <ExternalTextLink
                  href={link.url}
                  key={link.url}
                  text={link.name}
                />
              )) }
            </ButtonGroup>
          </div>
        ) : null }
      </Card.Body>
    </Card>
  )
}

ListIntro.propTypes = {
  listType: PropTypes.object.isRequired,
  selectedYear: PropTypes.number.isRequired,
  setSelectedYear: PropTypes.func.isRequired,
}

const ListsPage = () => {
  const { id } = useParams()
  const [listType, setListType] = useState(null)
  const [selectedYear, setSelectedYear] = useState(null)

  useEffect(() => {
    setListType(null)
    setSelectedYear(null)
    apiClient.getType(id).then(data => {
      setListType(data)
      setSelectedYear(data.public_lists[0]?.year || null)
    })
  }, [id])

  if (!listType || selectedYear === null) return 'Wait...'

  const selectedList = listType.public_lists.find(list => list.year === selectedYear)
  const bookIds = selectedList?.book_ids || []
  return (
    <>
      <PageConfigurer bookIds={bookIds} />

      <Layout classes='panels-page lists-page'>
        <Col xs={8}>
          <ListIntro
            listType={listType}
            selectedYear={selectedYear}
            setSelectedYear={setSelectedYear}
          />

          <BooksListCovers
            header='Noted Works'
            showControls={false}
          />
        </Col>

        <Col xs={4}>
          <div className='panel--selected-book--narrow'>
            <BookDetails
              header='Selected book'
              showCover={false}
            />
          </div>
        </Col>
      </Layout>
    </>
  )
}

export default ListsPage
