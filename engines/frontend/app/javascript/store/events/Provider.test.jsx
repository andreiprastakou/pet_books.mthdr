import React, { useCallback, useContext, useEffect } from 'react'
import PropTypes from 'prop-types'
import { cleanup, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import EventsContext from 'store/events/Context'
import EventsProvider from 'store/events/Provider'

afterEach(cleanup)

const apiRef = { current: null }

const handleProbeReady = function handleProbeReady(value) {
  apiRef.current = value
}

const Probe = ({ onReady }) => {
  const { subscribeToEvent, triggerEvent } = useContext(EventsContext)

  useEffect(() => {
    onReady({ subscribeToEvent, triggerEvent })
  }, [onReady, subscribeToEvent, triggerEvent])

  const handleClick = useCallback(() => triggerEvent('PING'), [triggerEvent])

  return (
    <button
      onClick={handleClick}
      type='button'
    >
      { 'ping' }
    </button>
  )
}

Probe.propTypes = {
  onReady: PropTypes.func.isRequired,
}

describe('events Provider', () => {
  it('notifies subscribers and stops after unsubscribe', async() => {
    const user = userEvent.setup()
    const subscriber = vi.fn()
    apiRef.current = null

    render(
      <EventsProvider>
        <Probe onReady={handleProbeReady} />
      </EventsProvider>
    )

    await waitFor(() => expect(apiRef.current).toBeDefined())
    const unsubscribe = apiRef.current.subscribeToEvent('PING', subscriber)

    await user.click(screen.getByRole('button', { name: 'ping' }))
    expect(subscriber).toHaveBeenCalledTimes(1)

    unsubscribe()
    await waitFor(() => expect(subscriber).toHaveBeenCalledTimes(1))
    await user.click(screen.getByRole('button', { name: 'ping' }))
    expect(subscriber).toHaveBeenCalledTimes(1)
  })

  it('ignores unknown events', async() => {
    const user = userEvent.setup()
    const subscriber = vi.fn()
    apiRef.current = null

    render(
      <EventsProvider>
        <Probe onReady={handleProbeReady} />
      </EventsProvider>
    )

    await waitFor(() => expect(apiRef.current).toBeDefined())
    apiRef.current.subscribeToEvent('PING', subscriber)
    apiRef.current.triggerEvent('OTHER')
    expect(subscriber).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'ping' }))
    expect(subscriber).toHaveBeenCalledTimes(1)
  })
})
