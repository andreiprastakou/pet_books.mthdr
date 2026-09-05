import { describe, expect, it } from 'vitest'

import { isNullish, notNullish } from 'utils/nullish'

describe('nullish', () => {
  it('treats null and undefined as nullish', () => {
    expect(isNullish(null)).toBe(true)
    expect(isNullish(undefined)).toBe(true)
    expect(notNullish(null)).toBe(false)
    expect(notNullish(undefined)).toBe(false)
  })

  it('treats other values as not nullish', () => {
    expect(isNullish(0)).toBe(false)
    expect(isNullish('')).toBe(false)
    expect(isNullish(false)).toBe(false)
    expect(notNullish(0)).toBe(true)
    expect(notNullish('')).toBe(true)
    expect(notNullish(false)).toBe(true)
  })
})
