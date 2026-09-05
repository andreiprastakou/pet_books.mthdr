import React, { useEffect, useState } from 'react'
import { Col } from 'react-bootstrap'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import Layout from 'pages/Layout'
import BookDetails from 'panels/bookDetails/BookDetails'
import BooksListCovers from 'panels/BooksListCovers'
import PublicListIntro from 'panels/publicListIntro/ListIntro'
import PageConfigurer from 'pages/publicListsPage/PageConfigurer'
import { setCurrentBookId } from 'store/axis/actions'
import { setRequestedBookId } from 'store/books/actions'
import apiClient from 'store/publicLists/apiClient'

const PublicListsPage = () => {
  const dispatch = useDispatch()
  const { id } = useParams()
  const [listType, setListType] = useState(null)
  const [selectedListId, setSelectedListId] = useState(null)
  const [selectedList, setSelectedList] = useState(null)

  useEffect(() => {
    setListType(null)
    setSelectedListId(null)
    setSelectedList(null)
    apiClient.getType(id).then(data => {
      setListType(data)
      setSelectedListId(data.public_lists?.[0]?.id ?? null)
    })
  }, [id])

  useEffect(() => {
    setSelectedList(null)
    if (selectedListId) apiClient.getList(selectedListId).then(setSelectedList)
  }, [selectedListId])

  const books = selectedList?.books || []
  const bookIds = books.map(book => book.id)
  const bookLabels = Object.fromEntries(books.map(book => [book.id, book.role || '']))

  useEffect(() => {
    if (selectedListId === null || bookIds.length === 0) {
      dispatch(setCurrentBookId(null))
      dispatch(setRequestedBookId(null))
    }
  }, [bookIds.length, dispatch, selectedListId])

  if (!listType) return 'Wait...'

  return (
    <>
      { selectedListId === null ? null : <PageConfigurer bookIds={bookIds} /> }

      <Layout classes='panels-page public-lists-page'>
        <Col xs={8}>
          <PublicListIntro
            listType={listType}
            selectedList={selectedList}
            selectedListId={selectedListId}
            setSelectedListId={setSelectedListId}
          />

          { selectedListId === null ? null : (
            <BooksListCovers
              bookLabels={bookLabels}
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
              showPublicLists={false}
            />
          </div>
        </Col>
      </Layout>
    </>
  )
}

export default PublicListsPage
