import React, { useEffect, useState } from 'react'
import { Col } from 'react-bootstrap'
import { useParams } from 'react-router-dom'

import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksListCovers from 'panels/BooksListCovers'
import ListIntro from 'panels/listIntro/ListIntro'
import PageConfigurer from 'pages/listsPage/PageConfigurer'
import apiClient from 'store/publicLists/apiClient'

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
