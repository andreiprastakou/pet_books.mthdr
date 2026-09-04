import { describe, expect, it } from 'vitest'

import EventsContext from 'store/events/Context'

describe('events Context', () => {
  it('exports a React context', () => {
    expect(EventsContext).toBeDefined()
    expect(EventsContext.Provider).toBeDefined()
  })
})
