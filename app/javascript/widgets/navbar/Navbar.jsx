import React, { useContext } from 'react'
import { useSelector } from 'react-redux'
import { Nav, Navbar, NavDropdown } from 'react-bootstrap'

import AuthorsNavList from 'widgets/navbar/components/AuthorsNavList'
import BooksNavList from 'widgets/navbar/components/BooksNavList'
import TagsNavList from 'widgets/navbar/components/TagsNavList'
import EventsContext from 'store/events/Context'
import UrlStoreContext from 'store/urlStore/Context'
import { selectTagIdBookmark, selectTagIdRead } from 'store/tags/selectors'

const PageNavbar = () => {
  const { routes: { authorsPagePath, booksPagePath, tagsPagePath, tagPagePath },
          actions: { goto },
          routesReady } = useContext(UrlStoreContext)
  const { triggerEvent } = useContext(EventsContext)
  const tagIdBookmark = useSelector(selectTagIdBookmark())
  const tagIdRead = useSelector(selectTagIdRead())

  if (!routesReady) return null

  return (
    <Navbar bg='dark' variant='dark' fixed='top' expand>
      <Nav className='mr-auto'>
        <Nav.Link onClick={ () => goto(booksPagePath()) }><b>Artspace | Literature</b></Nav.Link>

        <NavDropdown title='Books' onClick={ () => triggerEvent('BOOKS_NAV_CLICKED') }>
          <BooksNavList/>
          <NavDropdown.Divider />
          <NavDropdown.Item href={ booksPagePath() }>List all</NavDropdown.Item>
          <NavDropdown.Divider />
          <NavDropdown.Item href={ tagPagePath(tagIdBookmark) }>Bookmarked by me</NavDropdown.Item>
          <NavDropdown.Item href={ tagPagePath(tagIdRead) }>Read by me</NavDropdown.Item>
        </NavDropdown>

        <NavDropdown title='Authors' onClick={ () => triggerEvent('AUTHORS_NAV_CLICKED') }>
          <AuthorsNavList/>
          <NavDropdown.Divider />
          <NavDropdown.Item href={ authorsPagePath() }>List all</NavDropdown.Item>
          <NavDropdown.Divider />
        </NavDropdown>

        <NavDropdown title='Tags' onClick={ () => triggerEvent('TAGS_NAV_CLICKED') }>
          <TagsNavList/>
          <NavDropdown.Divider />
          <NavDropdown.Item href={ tagsPagePath() }>List all</NavDropdown.Item>
        </NavDropdown>

        <NavDropdown title='Awards'>
          <NavDropdown.Item href={ '/awards/booker' }>Booker Prize</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/campbell' }>Campbell Awards</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/goodreads' }>Goodreads Choice</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/hugo' }>Hugo</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/nebula' }>Nebula</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/nytimes' }>NY Times Bestsellers</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/pulitzer' }>Pulitzer Prize</NavDropdown.Item>
          <NavDropdown.Item href={ '/awards/prosvetitel' }>Просветитель</NavDropdown.Item>
        </NavDropdown>
      </Nav>
    </Navbar>
  )
}

export default PageNavbar
