import React from 'react'
import PropTypes from 'prop-types'
import { Provider as ReduxProvider } from 'react-redux'
import store from 'store/store'
import { Container } from 'react-bootstrap'
import { BrowserRouter } from 'react-router-dom'

import Notifications from 'widgets/notifications/Notifications'
import Modals from 'modals/AllModals'
import Navbar from 'widgets/navbar/Navbar'
import PageContent from 'components/PageContent'
import PageRouteHelpers from 'components/PageRouteHelpers'
import RootUrlStoreProvider from 'store/urlStore/RootStoreProvider'
import EventsProvider from 'store/events/Provider'
import { setDefaultAuthorImageUrl } from 'store/authors/actions'

/* eslint-disable camelcase */
const Page = ({ default_author_image_url }) => {
  store.dispatch(setDefaultAuthorImageUrl(default_author_image_url))

  return (
    <ReduxProvider store={store}>
      <BrowserRouter>
        <RootUrlStoreProvider>
          <EventsProvider>
            <PageRouteHelpers />

            <Modals />

            <Notifications />

            <Container className='page f-page-content-container'>
              <Navbar />

              <PageContent />
            </Container>
          </EventsProvider>
        </RootUrlStoreProvider>
      </BrowserRouter>
    </ReduxProvider>
  )
}

Page.propTypes = {
  default_author_image_url: PropTypes.string.isRequired,
  default_book_image_url: PropTypes.string.isRequired,
}
/* eslint-enable camelcase */

export default Page
