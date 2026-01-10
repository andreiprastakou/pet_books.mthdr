import { useContext, useEffect } from 'react'

import UrlStoreContext from 'store/urlStore/Context'

const ModalsRouteHelper = () => {
  const { getActions, getRoutes,
    helpers: { buildRelativePath },
  } = useContext(UrlStoreContext)
  const { addRoute, addUrlAction } = getActions()

  useEffect(() => {
    addRoute('modalClosedPath', () => buildRelativePath({ hash: '' }))

    addRoute('modalOpenPath', modalHash => buildRelativePath({ hash: modalHash }))

    addUrlAction('closeModal', () =>
      getActions().patch(getRoutes().modalClosedPath())
    )

    addUrlAction('openModal', modalHash =>
      getActions().patch(getRoutes().modalOpenPath(modalHash))
    )
  }, [])

  return null
}

export default ModalsRouteHelper
