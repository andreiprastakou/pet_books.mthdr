import React, { useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom'

import { setCurrentTagId } from 'store/axis/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import TagPage from 'pages/tagPage/Page'
import UrlStoreContext from 'store/urlStore/Context'

const Helper = () => {
  const { actions: { addRoute }, helpers: { buildPath } } = useContext(UrlStoreContext)

  useEffect(() => {
    addRoute('tagPagePath', id => buildPath({ path: `/tags/${id}` }))
  }, [])
  return null
}

const path = '/tags/:tagId'

const Renderer = () => (
  <>
    <LocalStoreConfigurer />

    <TagPage />
  </>
)

const LocalStoreConfigurer = () => {
  const params = useParams()
  const paramsRef = useRef()
  paramsRef.current = params
  const dispatch = useDispatch()

  const { actions: { addUrlState },
    pageState: { tagId }
  } = useContext(UrlStoreContext)

  useEffect(() => {
    addUrlState('tagId', () => parseInt(paramsRef.current.tagId))

    dispatch(setPageIsLoading(true))
    dispatch(setCurrentTagId(tagId))
  }, [tagId])

  return null
}

export default { path, Renderer, Helper }
