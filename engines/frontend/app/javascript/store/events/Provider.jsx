import React, { useMemo, useState } from 'react'
import PropTypes from 'prop-types'

import Context from 'store/events/Context'

const Provider = ({ children }) => {
  const [subscribers, setSubscribers] = useState({})

  const contextValue = useMemo(
    () => ({
      subscribeToEvent: (event, subscriber) => {
        setSubscribers(value => ({
          ...value,
          [event]: [...(value[event] || []), subscriber],
        }))
      },
      triggerEvent: event => {
        ;(subscribers[event] || []).forEach(subscriber => subscriber())
      },
    }),
    [subscribers],
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
