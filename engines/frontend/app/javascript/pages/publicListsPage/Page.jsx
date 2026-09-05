import React, { useContext, useEffect, useState } from 'react'
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
import UrlStoreContext from 'store/urlStore/Context'
import { isNullish } from 'utils/nullish'

const PublicListsPage = () => {
  const dispatch = useDispatch()
  const { id } = useParams()
  const {
    actions: { selectPublicList },
    pageState,
  } = useContext(UrlStoreContext)
  const { listId } = pageState
  const listIdReady = Object.hasOwn(pageState, 'listId')
  const [listType, setListType] = useState(null)
  const [selectedList, setSelectedList] = useState(null)

  useEffect(() => {
    setListType(null)
    setSelectedList(null)
    apiClient.getType(id).then(setListType)
  }, [id])

  useEffect(() => {
    if (!listType || !listIdReady || !selectPublicList) return

    const lists = listType.public_lists || []
    const listIds = lists.map(list => list.id)
    const nextId = listIds.includes(listId) ? listId : (lists[0]?.id ?? null)
    if (nextId !== listId) selectPublicList(nextId)
  }, [listType, listId, listIdReady, selectPublicList])

  useEffect(() => {
    setSelectedList(null)
    if (listId) apiClient.getList(listId).then(setSelectedList)
  }, [listId])

  const books = selectedList?.books || []
  const bookIds = books.map(book => book.id)
  const bookLabels = Object.fromEntries(books.map(book => [book.id, book.role || '']))

  useEffect(() => {
    if (!listIdReady) return
    if (isNullish(listId) || (selectedList && bookIds.length === 0)) {
      dispatch(setCurrentBookId(null))
      dispatch(setRequestedBookId(null))
    }
  }, [bookIds.length, dispatch, listId, listIdReady, selectedList])

  if (!listType) return 'Wait...'

  return (
    <>
      { isNullish(listId) ? null : <PageConfigurer bookIds={bookIds} /> }

      <Layout classes='panels-page public-lists-page'>
        <Col xs={8}>
          <PublicListIntro
            listType={listType}
            selectedList={selectedList}
            selectedListId={listId}
            setSelectedListId={selectPublicList}
          />

          { isNullish(listId) ? null : (
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
