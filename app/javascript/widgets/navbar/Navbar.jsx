import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Nav, Navbar, NavDropdown } from 'react-bootstrap'

import AuthorsNavList from 'widgets/navbar/components/AuthorsNavList'
import BooksNavList from 'widgets/navbar/components/BooksNavList'
import TagsNavList from 'widgets/navbar/components/TagsNavList'
import EventsContext from 'store/events/Context'
import UrlStoreContext from 'store/urlStore/Context'
import { selectTagIdBookmark, selectTagIdRead } from 'store/tags/selectors'

const PageNavbar = () => {
  const { routesReady } = useContext(UrlStoreContext)

  if (!routesReady) return null

  return (
    <Navbar
      bg='dark'
      expand
      fixed='top'
      variant='dark'
    >
      <Nav className='mr-auto'>
        <RootNavLink />

        <BooksNavDropdown />

        <AuthorsNavDropdown />

        <TagsNavDropdown />

        <AwardsNavDropdown />
      </Nav>
    </Navbar>
  )
}

const RootNavLink = () => {
  const { routes: { booksPagePath },
    actions: { goto },
    routesReady } = useContext(UrlStoreContext)

  if (!routesReady) return null

  const handleGotoRoot = useCallback(() => goto(booksPagePath()), [goto, booksPagePath])

  return (
    <Nav.Link onClick={handleGotoRoot}>
      <b>
        { 'Artspace | Literature' }
      </b>
    </Nav.Link>
  )
}

const BooksNavDropdown = () => {
  const { routes: { booksPagePath, tagPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)
  const tagIdBookmark = useSelector(selectTagIdBookmark())
  const tagIdRead = useSelector(selectTagIdRead())

  const handleTriggerEvent = useCallback(() => triggerEvent('BOOKS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Books'
    >
      <BooksNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item href={booksPagePath()}>
        { 'List all' }
      </NavDropdown.Item>

      <NavDropdown.Divider />

      <NavDropdown.Item href={tagPagePath(tagIdBookmark)}>
        { 'Bookmarked by me' }
      </NavDropdown.Item>

      <NavDropdown.Item href={tagPagePath(tagIdRead)}>
        { 'Read by me' }
      </NavDropdown.Item>
    </NavDropdown>
  )
}

const AuthorsNavDropdown = () => {
  const { routes: { authorsPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('AUTHORS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Authors'
    >
      <AuthorsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item href={authorsPagePath()}>
        { 'List all' }
      </NavDropdown.Item>

      <NavDropdown.Divider />
    </NavDropdown>
  )
}

const TagsNavDropdown = () => {
  const { routes: { tagsPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('TAGS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Tags'
    >
      <TagsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item href={tagsPagePath()}>
        { 'List all' }
      </NavDropdown.Item>
    </NavDropdown>
  )
}

const AwardsNavDropdown = () => (
  <NavDropdown title='Awards'>
    <NavDropdown.Item href="/awards/booker">
      { 'Booker Prize' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/campbell">
      { 'Campbell Awards' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/goodreads">
      { 'Goodreads Choice' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/hugo">
      { 'Hugo' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/nebula">
      { 'Nebula' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/nytimes">
      { 'NY Times Bestsellers' }
    </NavDropdown.Item>

    <NavDropdown.Item href="/awards/pulitzer">
      { 'Pulitzer Prize' }
    </NavDropdown.Item>
  </NavDropdown>
)

export default PageNavbar
