import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { Accordion, Offcanvas } from 'react-bootstrap'
import { useLocation } from 'react-router-dom'

import InternalLink from 'components/InternalLink'
import AuthorsNavList from 'components/navbar/AuthorsNavList'
import BooksNavList from 'components/navbar/BooksNavList'
import LogoutForm from 'components/navbar/LogoutForm'
import PublicListsNavList from 'components/navbar/ListsNavList'
import SeriesNavList from 'components/navbar/SeriesNavList'
import TagsNavList from 'components/navbar/TagsNavList'
import EventsContext from 'store/events/Context'
import UrlStoreContext from 'store/urlStore/Context'

const SECTION_EVENTS = {
  authors: 'AUTHORS_NAV_CLICKED',
  books: 'BOOKS_NAV_CLICKED',
  series: 'SERIES_NAV_CLICKED',
  tags: 'TAGS_NAV_CLICKED',
}

const isPlainLeftClick = event => {
  if (event.defaultPrevented || event.button !== 0) return false

  return !event.metaKey && !event.altKey && !event.ctrlKey && !event.shiftKey
}

const CompactNavToggle = ({ expanded, onClick }) => (
  <button
    aria-controls='page-nav-drawer'
    aria-expanded={expanded}
    aria-label={expanded ? 'Close menu' : 'Open menu'}
    className='page-navbar-burger'
    onClick={onClick}
    type='button'
  >
    <svg
      aria-hidden='true'
      className='page-navbar-burger-icon'
      fill='currentColor'
      viewBox='0 0 16 16'
    >
      <path d='M1 3.5h14v1.5H1zm0 4h14v1.5H1zm0 4h14V13H1z' />
    </svg>
  </button>
)

CompactNavToggle.propTypes = {
  expanded: PropTypes.bool.isRequired,
  onClick: PropTypes.func.isRequired,
}
const DrawerLink = ({ children, href }) => (
  <InternalLink
    className='page-nav-drawer-link'
    href={href}
  >
    { children }
  </InternalLink>
)

DrawerLink.propTypes = {
  children: PropTypes.node.isRequired,
  href: PropTypes.string.isRequired,
}

const DrawerSection = ({ children, eventKey, title }) => (
  <Accordion.Item eventKey={eventKey}>
    <Accordion.Header>
      { title }
    </Accordion.Header>

    <Accordion.Body>
      { children }
    </Accordion.Body>
  </Accordion.Item>
)

DrawerSection.propTypes = {
  children: PropTypes.node,
  eventKey: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
}

const BooksDrawerBody = () => {
  const { routes: { booksPagePath } } = useContext(UrlStoreContext)

  return (
    <>
      <BooksNavList />

      <hr className='page-nav-drawer-divider' />

      <DrawerLink href={booksPagePath()}>
        { 'List all' }
      </DrawerLink>
    </>
  )
}

const AuthorsDrawerBody = () => {
  const { routes: { authorsPagePath } } = useContext(UrlStoreContext)

  return (
    <>
      <AuthorsNavList />

      <hr className='page-nav-drawer-divider' />

      <DrawerLink href={authorsPagePath()}>
        { 'List all' }
      </DrawerLink>
    </>
  )
}

const TagsDrawerBody = () => {
  const { routes: { tagsPagePath } } = useContext(UrlStoreContext)

  return (
    <>
      <TagsNavList />

      <hr className='page-nav-drawer-divider' />

      <DrawerLink href={tagsPagePath()}>
        { 'List all' }
      </DrawerLink>
    </>
  )
}

const SeriesDrawerBody = () => {
  const { routes: { seriesIndexPagePath } } = useContext(UrlStoreContext)

  return (
    <>
      <SeriesNavList />

      <hr className='page-nav-drawer-divider' />

      <DrawerLink href={seriesIndexPagePath()}>
        { 'List all' }
      </DrawerLink>
    </>
  )
}

const AccountDrawerBody = ({ email }) => {
  const { routes: { pinBoardPagePath, readsPagePath } } = useContext(UrlStoreContext)

  return (
    <>
      <div className='page-nav-drawer-email'>
        { email }
      </div>

      <DrawerLink href={pinBoardPagePath()}>
        { 'Pin board' }
      </DrawerLink>

      <DrawerLink href={readsPagePath()}>
        { 'Your reads' }
      </DrawerLink>

      <LogoutForm />
    </>
  )
}

AccountDrawerBody.propTypes = {
  email: PropTypes.string.isRequired,
}

const CompactNavSections = ({ currentUserEmail, onSelect, openKey }) => (
  <Accordion
    activeKey={openKey}
    onSelect={onSelect}
  >
    <DrawerSection
      eventKey='books'
      title='Books'
    >
      { openKey === 'books' ? <BooksDrawerBody /> : null }
    </DrawerSection>

    <DrawerSection
      eventKey='authors'
      title='Authors'
    >
      { openKey === 'authors' ? <AuthorsDrawerBody /> : null }
    </DrawerSection>

    <DrawerSection
      eventKey='tags'
      title='Tags'
    >
      { openKey === 'tags' ? <TagsDrawerBody /> : null }
    </DrawerSection>

    <DrawerSection
      eventKey='series'
      title='Series'
    >
      { openKey === 'series' ? <SeriesDrawerBody /> : null }
    </DrawerSection>

    <DrawerSection
      eventKey='lists'
      title='Public lists'
    >
      { openKey === 'lists' ? <PublicListsNavList /> : null }
    </DrawerSection>

    { currentUserEmail ? (
      <DrawerSection
        eventKey='account'
        title='Account'
      >
        { openKey === 'account' ? <AccountDrawerBody email={currentUserEmail} /> : null }
      </DrawerSection>
    ) : null }
  </Accordion>
)

CompactNavSections.propTypes = {
  currentUserEmail: PropTypes.string,
  onSelect: PropTypes.func.isRequired,
  openKey: PropTypes.string.isRequired,
}

const CompactNavDrawer = ({ currentUserEmail, onHide, show }) => {
  const { pathname } = useLocation()
  const pathnameRef = useRef(pathname)
  const { triggerEvent } = useContext(EventsContext)
  const [openKey, setOpenKey] = useState('')

  useEffect(() => {
    if (pathnameRef.current === pathname) return

    pathnameRef.current = pathname
    onHide()
  }, [onHide, pathname])

  useEffect(() => {
    if (!show) setOpenKey('')
  }, [show])

  const handleSelect = useCallback(key => {
    const nextKey = key || ''

    setOpenKey(nextKey)
    const eventName = SECTION_EVENTS[nextKey]

    if (eventName) triggerEvent(eventName)
  }, [triggerEvent])

  const handleNavigate = useCallback(event => {
    if (!isPlainLeftClick(event)) return
    if (!event.target.closest('a[href]')) return

    onHide()
  }, [onHide])

  return (
    <Offcanvas
      aria-labelledby='page-nav-drawer-title'
      className='page-nav-drawer'
      id='page-nav-drawer'
      onHide={onHide}
      placement='end'
      show={show}
    >
      <Offcanvas.Header
        closeButton
        closeVariant='white'
      >
        <Offcanvas.Title id='page-nav-drawer-title'>
          { 'Menu' }
        </Offcanvas.Title>
      </Offcanvas.Header>

      <Offcanvas.Body onClick={handleNavigate}>
        <CompactNavSections
          currentUserEmail={currentUserEmail}
          onSelect={handleSelect}
          openKey={openKey}
        />
      </Offcanvas.Body>
    </Offcanvas>
  )
}

CompactNavDrawer.propTypes = {
  currentUserEmail: PropTypes.string,
  onHide: PropTypes.func.isRequired,
  show: PropTypes.bool.isRequired,
}

export { CompactNavDrawer, CompactNavToggle }
