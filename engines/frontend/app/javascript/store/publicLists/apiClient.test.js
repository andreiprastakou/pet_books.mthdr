import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/publicLists/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('publicLists apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
    jQuery.ajax.mockResolvedValue({ ok: true })
  })

  it('requests public list types and lists', async() => {
    await apiClient.getTypes()
    await apiClient.getType(3)
    await apiClient.getList(9)

    expect(jQuery.ajax).toHaveBeenNthCalledWith(1, { url: '/api/public_list_types.json' })
    expect(jQuery.ajax).toHaveBeenNthCalledWith(2, { url: '/api/public_list_types/3.json' })
    expect(jQuery.ajax).toHaveBeenNthCalledWith(3, { url: '/api/public_lists/9.json' })
  })
})
