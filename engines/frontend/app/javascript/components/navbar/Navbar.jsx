import React, { useCallback, useContext, useEffect, useState } from 'react'
import PropTypes from 'prop-types'
import { Nav, Navbar, NavDropdown } from 'react-bootstrap'

import InternalLink from 'components/InternalLink'
import { CompactNavDrawer, CompactNavToggle } from 'components/navbar/CompactNav'
import AuthorsNavList from 'components/navbar/AuthorsNavList'
import BooksNavList from 'components/navbar/BooksNavList'
import LogoutForm from 'components/navbar/LogoutForm'
import TagsNavList from 'components/navbar/TagsNavList'
import SeriesNavList from 'components/navbar/SeriesNavList'
import PublicListsNavList from 'components/navbar/ListsNavList'
import useCompactLayout from 'hooks/useCompactLayout'
import EventsContext from 'store/events/Context'
import UrlStoreContext from 'store/urlStore/Context'

const PageNavbar = ({ currentUserEmail }) => {
  const { routesReady } = useContext(UrlStoreContext)
  const compact = useCompactLayout()
  const [drawerOpen, setDrawerOpen] = useState(false)
  const closeDrawer = useCallback(() => setDrawerOpen(false), [])
  const toggleDrawer = useCallback(() => setDrawerOpen(open => !open), [])

  useEffect(() => {
    if (!compact) setDrawerOpen(false)
  }, [compact])

  if (!routesReady) return null

  return (
    <Navbar
      bg='dark'
      className='page-navbar'
      expand
      fixed='top'
      variant='dark'
    >
      <div className='page-navbar-inner'>
        <Nav className='page-navbar-brand'>
          <RootNavLink />
        </Nav>

        { compact ? (
          <CompactNavToggle
            expanded={drawerOpen}
            onClick={toggleDrawer}
          />
        ) : (
          <DesktopNav currentUserEmail={currentUserEmail} />
        ) }
      </div>

      { compact ? (
        <CompactNavDrawer
          currentUserEmail={currentUserEmail}
          onHide={closeDrawer}
          show={drawerOpen}
        />
      ) : null }
    </Navbar>
  )
}

PageNavbar.propTypes = {
  currentUserEmail: PropTypes.string,
}

const AccountNav = ({ email }) => {
  const { routes: { pinBoardPagePath, readsPagePath } } = useContext(UrlStoreContext)

  return (
    <Nav className='page-navbar-account'>
      <NavDropdown
        align='end'
        id='account-menu'
        title={(
          <>
            <ProfileIcon />

            <span className='page-navbar-account-label'>
              { 'Account' }
            </span>
          </>
        )}
      >
        <NavDropdown.ItemText>
          { email }
        </NavDropdown.ItemText>

        <NavDropdown.Divider />

        <NavDropdown.Item
          as={InternalLink}
          href={pinBoardPagePath()}
        >
          { 'Pin board' }
        </NavDropdown.Item>

        <NavDropdown.Item
          as={InternalLink}
          href={readsPagePath()}
        >
          { 'Your reads' }
        </NavDropdown.Item>

        <LogoutForm />
      </NavDropdown>
    </Nav>
  )
}

AccountNav.propTypes = {
  email: PropTypes.string.isRequired,
}

const ProfileIcon = () => (
  <svg
    aria-hidden='true'
    className='page-navbar-account-icon'
    fill='currentColor'
    viewBox='0 0 16 16'
  >
    <path d='M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m4 1.5a.5.5 0 0 0-.5-.5h-7a.5.5 0 0 0-.5.5V11c0 1.7 2 3 4 3s4-1.3 4-3z' />
  </svg>
)

const DesktopNav = ({ currentUserEmail }) => (
  <>
    <Nav className='page-navbar-sections'>
      <BooksNavDropdown />

      <AuthorsNavDropdown />

      <TagsNavDropdown />

      <SeriesNavDropdown />

      <PublicListsNavDropdown />
    </Nav>

    { currentUserEmail ? <AccountNav email={currentUserEmail} /> : null }
  </>
)

DesktopNav.propTypes = {
  currentUserEmail: PropTypes.string,
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

const SeriesNavDropdown = () => {
  const { routes: { seriesIndexPagePath } } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)

  const handleTriggerEvent = useCallback(() => triggerEvent('SERIES_NAV_CLICKED'), [triggerEvent])

  return (
    <NavDropdown
      onClick={handleTriggerEvent}
      title='Series'
    >
      <SeriesNavList />

      <NavDropdown.Divider />

      <NavDropdown.Item
        as={InternalLink}
        href={seriesIndexPagePath()}
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
