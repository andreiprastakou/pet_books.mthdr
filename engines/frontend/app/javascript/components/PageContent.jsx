import React from 'react'
import { Switch, Route, Redirect } from 'react-router-dom'

import BookerPage from 'pages/awards/bookerPage/Page'
import CampbellPage from 'pages/awards/campbellPage/Page'
import GoodreadsChoicePage from 'pages/awards/goodreadsPage/Page'
import HugoPage from 'pages/awards/hugoPage/Page'
import NebulaPage from 'pages/awards/nebulaPage/Page'
import NYTimesPage from 'pages/awards/nyTimesPage/Page'
import PulitzerPage from 'pages/awards/pulitzerPage/Page'

import pageRoutes from 'components/pageRoutes'

const PageContent = () => (
  <Switch>
    <Route
      exact
      path='/'
    >
      <Redirect to='/books' />
    </Route>

    { pageRoutes.map(route => (
      <Route
        key={route.path}
        path={route.path}
      >
        <route.Renderer />
      </Route>
    )) }

    <Route path='/awards/booker'>
      <BookerPage />
    </Route>

    <Route path='/awards/campbell'>
      <CampbellPage />
    </Route>

    <Route path='/awards/goodreads'>
      <GoodreadsChoicePage />
    </Route>

    <Route path='/awards/hugo'>
      <HugoPage />
    </Route>

    <Route path='/awards/nebula'>
      <NebulaPage />
    </Route>

    <Route path='/awards/nytimes'>
      <NYTimesPage />
    </Route>

    <Route path='/awards/pulitzer'>
      <PulitzerPage />
    </Route>

    <Route path='/:foobar'>
      { 'UNKNOWN ROUTE' }
    </Route>
  </Switch>
)

export default PageContent
