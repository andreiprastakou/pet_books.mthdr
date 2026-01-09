import React from 'react'
import pageRoutes from 'components/pageRoutes'

import ModalsHelper from 'modals/RouteHelper'

const PageRouteHelpers = () => (
  <>
    <ModalsHelper />

    { pageRoutes.map(route =>
      <route.Helper key={route.path} />
    ) }
  </>
)

export default PageRouteHelpers
