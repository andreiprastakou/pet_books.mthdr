import React, { useCallback, useMemo, useState } from 'react'
import PropTypes from 'prop-types'

import Context from 'store/events/Context'

const Provider = ({ children }) => {
  const [subscribers, setSubscribers] = useState({})

  const subscribeToEvent = useCallback((event, subscriber) => {
    setSubscribers(value => ({
      ...value,
      [event]: [...(value[event] || []), subscriber],
    }))

    return () => {
      setSubscribers(value => {
        const eventSubscribers = value[event] || []
        const remainingSubscribers = eventSubscribers.filter(
          currentSubscriber => currentSubscriber !== subscriber,
        )

        return remainingSubscribers.length === eventSubscribers.length
          ? value
          : { ...value, [event]: remainingSubscribers }
      })
    }
  }, [])

  const triggerEvent = useCallback(
    event => {
      ;(subscribers[event] || []).forEach(subscriber => subscriber())
    },
    [subscribers],
  )

  const contextValue = useMemo(
    () => ({ subscribeToEvent, triggerEvent }),
    [subscribeToEvent, triggerEvent],
  )

  return (
    <Context.Provider value={contextValue}>
      {children}
    </Context.Provider>
  )
}

Provider.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Provider
