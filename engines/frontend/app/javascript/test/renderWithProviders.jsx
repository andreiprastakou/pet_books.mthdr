import React from 'react'
import PropTypes from 'prop-types'
import { Provider as ReduxProvider } from 'react-redux'
import { cleanup, render } from '@testing-library/react'
import { afterEach, vi } from 'vitest'

import EventsContext from 'store/events/Context'
import EventsProvider from 'store/events/Provider'
import { createAppStore } from 'store/store'
import UrlStoreContext from 'store/urlStore/Context'

afterEach(cleanup)

export const createUrlStoreValue = (overrides = {}) => {
  const {
    actions: actionOverrides = {},
    routes: routeOverrides = {},
    ...restOverrides
  } = overrides

  const routes = {
    authorPagePath: id => `/authors/${id}`,
    authorsPagePath: () => '/authors',
    booksPagePath: ({ bookId } = {}) => (bookId ? `/books/${bookId}` : '/books'),
    listPagePath: id => `/lists/${id}`,
    tagPagePath: id => `/tags/${id}`,
    tagsPagePath: () => '/tags',
    ...routeOverrides,
  }

  const actions = {
    goto: vi.fn(),
    showBooksIndexEntry: vi.fn(),
    switchToIndexPage: vi.fn(),
    switchToIndexSort: vi.fn(),
    ...actionOverrides,
  }

  return {
    actions,
    getActions: () => actions,
    getRoutes: () => routes,
    helpers: {},
    pageState: {},
    routes,
    routesReady: true,
    ...restOverrides,
  }
}

export const createEventsValue = (overrides = {}) => ({
  subscribeToEvent: vi.fn(() => vi.fn()),
  triggerEvent: vi.fn(),
  ...overrides,
})

const Providers = ({ children, store, urlStoreValue, eventsValue }) => {
  const content = (
    <ReduxProvider store={store}>
      <UrlStoreContext.Provider value={urlStoreValue}>
        { children }
      </UrlStoreContext.Provider>
    </ReduxProvider>
  )

  if (eventsValue)
    return (
      <EventsContext.Provider value={eventsValue}>
        { content }
      </EventsContext.Provider>
    )

  return (
    <EventsProvider>
      { content }
    </EventsProvider>
  )
}

Providers.propTypes = {
  children: PropTypes.node.isRequired,
  eventsValue: PropTypes.object,
  store: PropTypes.object.isRequired,
  urlStoreValue: PropTypes.object.isRequired,
}

export const renderWithProviders = (ui, {
  preloadedState,
  store = createAppStore(preloadedState),
  urlStore = {},
  events = null,
  ...renderOptions
} = {}) => {
  const urlStoreValue = createUrlStoreValue(urlStore)
  const eventsValue = events ? createEventsValue(events) : null

  const Wrapper = ({ children }) => (
    <Providers
      eventsValue={eventsValue}
      store={store}
      urlStoreValue={urlStoreValue}
    >
      { children }
    </Providers>
  )

  Wrapper.propTypes = {
    children: PropTypes.node,
  }

  return {
    store,
    urlStore: urlStoreValue,
    events: eventsValue,
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
  }
}
