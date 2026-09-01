import React, { useEffect, useState } from 'react'
import { Col } from 'react-bootstrap'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksListCovers from 'panels/BooksListCovers'
import PublicListIntro from 'panels/listIntro/ListIntro'
import PageConfigurer from 'pages/listsPage/PageConfigurer'
import { setCurrentBookId } from 'store/axis/actions'
import { setRequestedBookId } from 'store/books/actions'
import apiClient from 'store/publicLists/apiClient'

const PublicListsPage = () => {
  const dispatch = useDispatch()
  const { id } = useParams()
  const [listType, setListType] = useState(null)
  const [selectedYear, setSelectedYear] = useState(null)

  useEffect(() => {
    setListType(null)
    setSelectedYear(null)
    apiClient.getType(id).then(data => {
      setListType(data)
      setSelectedYear(data.public_lists?.[0]?.year ?? null)
    })
  }, [id])

  const selectedList = listType?.public_lists?.find(list => list.year === selectedYear)
  const bookIds = selectedList?.book_ids || []

  useEffect(() => {
    if (selectedYear === null || bookIds.length === 0) {
      dispatch(setCurrentBookId(null))
      dispatch(setRequestedBookId(null))
    }
  }, [bookIds.length, dispatch, selectedYear])

  if (!listType) return 'Wait...'

  return (
    <>
      { selectedYear === null ? null : <PageConfigurer bookIds={bookIds} /> }

      <Layout classes='panels-page public-lists-page'>
        <Col xs={8}>
          <PublicListIntro
            listType={listType}
            selectedYear={selectedYear}
            setSelectedYear={setSelectedYear}
          />

          { selectedYear === null ? null : (
            <BooksListCovers
              header='Noted Works'
              showControls={false}
            />
          ) }
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

export default PublicListsPage
