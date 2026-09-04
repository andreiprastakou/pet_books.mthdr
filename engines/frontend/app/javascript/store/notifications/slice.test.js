import { configureStore } from '@reduxjs/toolkit'
import { describe, expect, it, vi } from 'vitest'

import reducer, { slice } from 'store/notifications/slice'
import {
  addErrorMessage,
  addSuccessMessage,
} from 'store/notifications/actions'
import { selectMessages } from 'store/notifications/selectors'

const { addMessage, removeMessage } = slice.actions

describe('notifications slice', () => {
  it('starts with no messages', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({ messages: [] })
  })

  it('adds a message with a timestamp id and removes by id', () => {
    vi.spyOn(Date.prototype, 'getTime').mockReturnValue(42)
    const withMessage = reducer(undefined, addMessage({ type: 'success', message: 'Saved' }))

    expect(withMessage.messages).toEqual([
      { type: 'success', message: 'Saved', id: 42 },
    ])

    const cleared = reducer(withMessage, removeMessage(42))
    expect(cleared.messages).toEqual([])
  })
})

describe('notifications actions', () => {
  const makeStore = () => configureStore({
    reducer: { notifications: reducer },
  })

  it('wraps success and error helpers', () => {
    vi.spyOn(Date.prototype, 'getTime').mockReturnValue(7)
    const store = makeStore()

    store.dispatch(addSuccessMessage('ok'))
    store.dispatch(addErrorMessage('nope'))

    expect(store.getState().notifications.messages).toEqual([
      { type: 'success', message: 'ok', id: 7 },
      { type: 'danger', message: 'nope', id: 7 },
    ])
  })
})

describe('notifications selectors', () => {
  it('selects messages', () => {
    const messages = [{ id: 1, type: 'success', message: 'hi' }]
    expect(selectMessages()({ notifications: { messages } })).toEqual(messages)
  })
})
