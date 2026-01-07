import React, { useState } from 'react'

import Context from 'store/events/Context'

function Provider(props) {
  const [subscribers, setSubscribers] = useState({})

  const contextValue = {
    subscribeToEvent: (event, subscriber) => {
      setSubscribers(value => ({ ...value, [event]: [...(value[event] || []), subscriber] }))
    },
    triggerEvent: event => {
      (subscribers[event] || []).forEach(subscriber => subscriber())
    },
  }

  return (
    <Context.Provider value={contextValue}>
      {props.children}
    </Context.Provider>
  )
}

export default Provider
