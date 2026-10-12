import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/userPinsSharings/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('user pins sharings apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
    document.head.innerHTML = '<meta name="csrf-token" content="tok">'
  })

  it('creates and fetches a sharing code', async() => {
    jQuery.ajax.mockImplementation(() => ({
      then: (onFulfilled, onRejected) => Promise.resolve({ code: 'abc' }).then(onFulfilled, onRejected),
    }))

    const created = apiClient.create()
    expect(created.finally).toEqual(expect.any(Function))
    await expect(created).resolves.toEqual({ code: 'abc' })
    await apiClient.get('abc')

    expect(jQuery.ajax).toHaveBeenNthCalledWith(1, {
      url: '/api/user_pins_sharings.json',
      method: 'POST',
      headers: { 'X-CSRF-Token': 'tok' },
    })
    expect(jQuery.ajax).toHaveBeenNthCalledWith(2, {
      url: '/api/user_pins_sharings/abc.json',
    })

    await apiClient.current()
    await apiClient.destroy()

    expect(jQuery.ajax).toHaveBeenNthCalledWith(3, {
      url: '/api/user_pins_sharings/current.json',
    })
    expect(jQuery.ajax).toHaveBeenNthCalledWith(4, {
      url: '/api/user_pins_sharings/current.json',
      method: 'DELETE',
      headers: { 'X-CSRF-Token': 'tok' },
    })
  })
})
