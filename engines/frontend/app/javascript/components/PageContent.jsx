import React from 'react'
import { Switch, Route, Redirect } from 'react-router-dom'

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

    <Route path='/:foobar'>
      { 'UNKNOWN ROUTE' }
    </Route>
  </Switch>
)

export default PageContent
