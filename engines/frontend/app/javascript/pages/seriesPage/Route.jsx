import React, { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import { setCurrentSeriesId } from 'store/axis/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import SeriesPage from 'pages/seriesPage/Page'
import UrlStoreContext from 'store/urlStore/Context'
import BooksListConfigurer from 'store/urlStore/BooksListConfigurer'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeRoute = addRoute('seriesPagePath', (id, { bookId } = {}) =>
      buildPath({ path: `/series/${id}`, params: { 'book_id': bookId } }))
    return removeRoute
  }, [])
  return null
}

const path = '/series/:seriesId'

const Renderer = () => (
  <>
    <BooksListConfigurer />

    <LocalStoreConfigurer />

    <SeriesPage />
  </>
)

const LocalStoreConfigurer = () => {
  const params = useParams()
  const paramsRef = useRef()
  paramsRef.current = params
  const dispatch = useDispatch()

  const { actions: { addUrlState },
    pageState: { seriesId }
  } = useContext(UrlStoreContext)

  useEffect(() => {
    const removeSeriesState = addUrlState('seriesId', () => parseInt(paramsRef.current.seriesId))

    dispatch(setPageIsLoading(true))
    dispatch(setCurrentSeriesId(seriesId))

    return removeSeriesState
  }, [seriesId])

  return null
}

export default { path, Renderer, Helper }
