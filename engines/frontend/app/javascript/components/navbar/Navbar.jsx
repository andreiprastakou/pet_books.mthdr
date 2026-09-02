import React, { useCallback, useContext } from 'react'
import { useSelector } from 'react-redux'
import { Nav, Navbar, NavDropdown } from 'react-bootstrap'

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
      className='internal-link'
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

  const handleTriggerEvent = useCallback(() => triggerEvent('BOOKS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Books'
    >
      <BooksNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        className='internal-link'
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

  const handleTriggerEvent = useCallback(() => triggerEvent('AUTHORS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Authors'
    >
      <AuthorsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        className='internal-link'
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

  const handleTriggerEvent = useCallback(() => triggerEvent('TAGS_NAV_CLICKED'), [])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Tags'
    >
      <TagsNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        className='internal-link'
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
