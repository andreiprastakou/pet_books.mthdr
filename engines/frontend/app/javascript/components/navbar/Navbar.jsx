import React, { useCallback, useContext } from 'react'
import { Nav, Navbar, NavDropdown } from 'react-bootstrap'

import InternalLink from 'components/InternalLink'
import AuthorsNavList from 'components/navbar/AuthorsNavList'
import BooksNavList from 'components/navbar/BooksNavList'
import TagsNavList from 'components/navbar/TagsNavList'
import PublicListsNavList from 'components/navbar/ListsNavList'
import EventsContext from 'store/events/Context'
import UrlStoreContext from 'store/urlStore/Context'

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

        <PublicListsNavDropdown />
      </Nav>
    </Navbar>
  )
}

const RootNavLink = () => {
  const { routes: { booksPagePath }, routesReady } = useContext(UrlStoreContext)

  if (!routesReady) return null

  return (
    <Nav.Link
      as={InternalLink}
      href={booksPagePath({ bookId: null })}
    >
      <b>
        { 'Artspace | Literature' }
      </b>
    </Nav.Link>
  )
}

const BooksNavDropdown = () => {
  const { routes: { booksPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('BOOKS_NAV_CLICKED'), [triggerEvent])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Books'
    >
      <BooksNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        as={InternalLink}
        href={booksPagePath()}
      >
        { 'List all' }
      </NavDropdown.Item>
    </NavDropdown>
  )
}

const AuthorsNavDropdown = () => {
  const { routes: { authorsPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('AUTHORS_NAV_CLICKED'), [triggerEvent])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Authors'
    >
      <AuthorsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        as={InternalLink}
        href={authorsPagePath()}
      >
        { 'List all' }
      </NavDropdown.Item>
    </NavDropdown>
  )
}

const TagsNavDropdown = () => {
  const { routes: { tagsPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('TAGS_NAV_CLICKED'), [triggerEvent])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Tags'
    >
      <TagsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        as={InternalLink}
        href={tagsPagePath()}
      >
        { 'List all' }
      </NavDropdown.Item>
    </NavDropdown>
  )
}

const PublicListsNavDropdown = () => (
  <NavDropdown title='Public lists'>
    <PublicListsNavList />
  </NavDropdown>
)

export default PageNavbar
