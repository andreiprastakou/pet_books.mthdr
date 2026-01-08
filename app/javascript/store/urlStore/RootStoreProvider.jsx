import React, { useEffect, useMemo, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useLocation, useHistory } from 'react-router-dom'

import { objectToParams } from 'utils/objectToParams'
import Context from 'store/urlStore/Context'

const Provider = ({ children }) => {
  const history = useHistory()
  const location = useLocation()

  const [urlActions, setUrlActions] = useState({})
  const actionsRef = useRef()
  actionsRef.current = urlActions
  const [pageState, setPageState] = useState({})
  const [stateDefiners, setStateDefiners] = useState({})
  const [routes, setRoutes] = useState({})
  const routesRef = useRef(routes)
  routesRef.current = routes
  const locationRef = useRef({})
  locationRef.current = location
  const [routesReady, setRoutesReady] = useState(false)
  useEffect(() => setRoutesReady(true), [])

  const urlAccessor = new UrlAccessor({ location: locationRef.current })

  const currentActions = {
    ...actionsRef.current,
    addRoute: (name, builder) => setRoutes(value => ({ ...value, [name]: builder })),
    addUrlAction: (name, action) => setUrlActions(value => ({ ...value, [name]: action })),
    addUrlState: (name, definer) => setStateDefiners(value => ({ ...value, [name]: definer })),
    updateLocation: newLocation => {
      locationRef.current = newLocation
      updatePageState()
    },
    goto: path => history.push(path),
    patch: path => history.replace(path),
  }

  const contextValue = useMemo(() => ({
    pageState,
    actions: currentActions,
    helpers: {
      buildPath,
      buildRelativePath: callToBuildRelativePath(locationRef),
    },
    routes: { ...routesRef.current },
    getRoutes: () => routesRef.current,
    getActions: () => currentActions,
    routesReady,
  }), [pageState, currentActions, routesRef.current, routesReady])

  const updatePageState = () => {
    const newPageState = Object.keys(stateDefiners).reduce((newState, key) => (
      { ...newState, [key]: stateDefiners[key](urlAccessor) }
    ), {})
    setPageState(newPageState)
  }

  useEffect(() => {
    updatePageState()
  }, [location, stateDefiners])

  return (
    <Context.Provider value={contextValue}>
      { children }
    </Context.Provider>
  )
}

class UrlAccessor {
  constructor({ location }) {
    this.location = location
    this.query = new URLSearchParams(location.search)
    this.hash = location.hash
  }

  queryParameter(name) {
    return this.query.get(name)
  }
}

const buildPath = ({ path, params, initialParams = '', hash } = {}) => {
  const newPath = [
    path,
    objectToParams(params ?? {}, initialParams),
    hash,
  ].join('')
  return newPath
}

const callToBuildRelativePath = locationRef => ({ path, params, hash } = {}) => {
  const location = locationRef.current
  return buildPath({
    path: path ?? location.pathname,
    params,
    initialParams: location.search,
    hash: hash ?? location.hash
  })
}

Provider.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Provider
