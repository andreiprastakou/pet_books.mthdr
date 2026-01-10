import React, { useContext, useCallback } from 'react'
import { useSelector } from 'react-redux'
import { Row, Col } from 'react-bootstrap'
import { HotKeys } from 'react-hotkeys'

import { selectSortedAuthors } from 'pages/authorsPage/selectors'

import Layout from 'pages/Layout'
import AuthorsIndexControls from 'sidebar/authorsIndexControls/Controls'
import AuthorsListItem from 'pages/authorsPage/components/AuthorsListItem'
import AuthorCard from 'sidebar/authorCard/AuthorCard'
import PageConfigurer from 'pages/authorsPage/PageConfigurer'
import UrlStoreContext from 'store/urlStore/Context'

const AuthorsPage = () => {
  const { pageState: { sortOrder }, actions: { removeAuthorWidget } } = useContext(UrlStoreContext)
  const authors = useSelector(selectSortedAuthors(sortOrder))

  const keyMap = {
    SHIFT_ON: { sequence: 'shift', action: 'keydown' },
    SHIFT_OFF: { sequence: 'shift', action: 'keyup' },
    UP: 'Up',
  }

  const handleCardClose = useCallback(() => removeAuthorWidget(), [])

  return (
    <>
      <PageConfigurer />

      <HotKeys
        keyMap={keyMap}
      >
        <Layout classes='authors-list-page'>
          <Col sm={4}>
            <div className='page-sidebar'>
              <AuthorCard onClose={handleCardClose} />

              <AuthorsIndexControls />
            </div>
          </Col>

          <Col sm={8}>
            <Row className='authors-list'>
              { authors.map(author => (
                <AuthorsListItem
                  author={author}
                  key={author.id}
                />
              )) }
            </Row>
          </Col>
        </Layout>
      </HotKeys>
    </>
  )
}

export default AuthorsPage
