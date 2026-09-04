import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import PropTypes from 'prop-types'
import { useLocation, useHistory } from 'react-router-dom'

import { objectToParams } from 'utils/objectToParams'
import Context from 'store/urlStore/Context'

const usePanelFocus = () => {
  const [registeredPanelIds, setRegisteredPanelIds] = useState([])
  const [activePanelId, setActivePanelId] = useState(null)
  const registeredPanelIdsRef = useRef(registeredPanelIds)
  registeredPanelIdsRef.current = registeredPanelIds

  const registerPanel = useCallback(id => setRegisteredPanelIds(value => (
    value.includes(id) ? value : [...value, id]
  )), [])
  const unregisterPanel = useCallback(id => {
    setRegisteredPanelIds(value => value.filter(panelId => panelId !== id))
    setActivePanelId(value => value === id ? null : value)
  }, [])
  const activatePanel = useCallback(id => {
    if (registeredPanelIdsRef.current.includes(id)) setActivePanelId(id)
  }, [])
  const deactivatePanel = useCallback(id => setActivePanelId(value => value === id ? null : value), [])
  const actions = useMemo(() => ({
    registerPanel,
    unregisterPanel,
    activatePanel,
    deactivatePanel,
  }), [registerPanel, unregisterPanel, activatePanel, deactivatePanel])

  return {
    activePanelId,
    registeredPanelIds,
    actions,
  }
}

const useUrlActions = ({
  history,
  locationRef,
  setRoutes,
  setUrlActions,
  setStateDefiners,
  urlActions,
  panelFocusActions,
  updatePageState,
}) => {
  const addRoute = useCallback((name, builder) => {
    setRoutes(value => ({ ...value, [name]: builder }))
    return () => setRoutes(value => {
      if (value[name] !== builder) return value
      const remaining = { ...value }
      delete remaining[name]
      return remaining
    })
  }, [setRoutes])
  const addUrlAction = useCallback((name, action) => {
    setUrlActions(value => ({ ...value, [name]: action }))
    return () => setUrlActions(value => {
      if (value[name] !== action) return value
      const remaining = { ...value }
      delete remaining[name]
      return remaining
    })
  }, [setUrlActions])
  const addUrlState = useCallback((name, definer) => {
    setStateDefiners(value => ({ ...value, [name]: definer }))
    return () => setStateDefiners(value => {
      if (value[name] !== definer) return value
      const remaining = { ...value }
      delete remaining[name]
      return remaining
    })
  }, [setStateDefiners])
  const updateLocation = useCallback(newLocation => {
    locationRef.current = newLocation
    updatePageState()
  }, [locationRef, updatePageState])
  const goto = useCallback(path => history.push(path), [history])
  const patch = useCallback(path => history.replace(path), [history])

  return useMemo(() => ({
    ...urlActions,
    ...panelFocusActions,
    addRoute,
    addUrlAction,
    addUrlState,
    updateLocation,
    goto,
    patch,
  }), [urlActions, panelFocusActions, addRoute, addUrlAction, addUrlState, updateLocation, goto, patch])
}

const Provider = ({ children }) => {
  const history = useHistory(), location = useLocation()

  const [urlActions, setUrlActions] = useState({})
  const [pageState, setPageState] = useState({})
  const {
    activePanelId,
    registeredPanelIds,
    actions: panelFocusActions,
  } = usePanelFocus()
  const [stateDefiners, setStateDefiners] = useState({})
  const [routes, setRoutes] = useState({})
  const routesRef = useRef(routes)
  routesRef.current = routes
  const locationRef = useRef({})
  locationRef.current = location
  const [routesReady, setRoutesReady] = useState(false)
  useEffect(() => setRoutesReady(true), [])

  const updatePageState = useCallback(() => {
    const urlAccessor = new UrlAccessor({ location: locationRef.current })
    const newPageState = Object.keys(stateDefiners).reduce((newState, key) => (
      { ...newState, [key]: stateDefiners[key](urlAccessor) }
    ), {})
    setPageState(newPageState)
  }, [stateDefiners])

  const currentActions = useUrlActions({
    history,
    locationRef,
    setRoutes,
    setUrlActions,
    setStateDefiners,
    urlActions,
    panelFocusActions,
    updatePageState,
  })
  const helpers = useMemo(() => ({
    buildPath,
    buildRelativePath: callToBuildRelativePath(locationRef),
  }), [])
  const getRoutes = useCallback(() => routesRef.current, [])
  const getActions = useCallback(() => currentActions, [currentActions])
  const contextValue = useMemo(() => ({
    pageState: { ...pageState, activePanelId, registeredPanelIds },
    actions: currentActions,
    helpers,
    routes: { ...routes },
    getRoutes,
    getActions,
    routesReady,
  }), [
    pageState, activePanelId, registeredPanelIds, currentActions,
    helpers, routes, getRoutes, getActions, routesReady,
  ])

  useEffect(() => {
    updatePageState()
  }, [location, stateDefiners, updatePageState])

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

export const buildPath = ({ path, params, initialParams = '', hash } = {}) => {
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
