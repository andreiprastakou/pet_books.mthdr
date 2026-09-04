import React, { useContext, useEffect } from 'react'
import { cleanup, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import EventsContext from 'store/events/Context'
import EventsProvider from 'store/events/Provider'

afterEach(cleanup)

const Probe = ({ onReady }) => {
  const { subscribeToEvent, triggerEvent } = useContext(EventsContext)

  useEffect(() => {
    onReady({ subscribeToEvent, triggerEvent })
  }, [onReady, subscribeToEvent, triggerEvent])

  return (
    <button
      onClick={() => triggerEvent('PING')}
      type='button'
    >
      { 'ping' }
    </button>
  )
}

describe('events Provider', () => {
  it('notifies subscribers and stops after unsubscribe', async() => {
    const user = userEvent.setup()
    const subscriber = vi.fn()
    let api

    render(
      <EventsProvider>
        <Probe onReady={value => { api = value }} />
      </EventsProvider>
    )

    await waitFor(() => expect(api).toBeDefined())
    const unsubscribe = api.subscribeToEvent('PING', subscriber)

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
    let api

    render(
      <EventsProvider>
        <Probe onReady={value => { api = value }} />
      </EventsProvider>
    )

    await waitFor(() => expect(api).toBeDefined())
    api.subscribeToEvent('PING', subscriber)
    api.triggerEvent('OTHER')
    expect(subscriber).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'ping' }))
    expect(subscriber).toHaveBeenCalledTimes(1)
  })
})
