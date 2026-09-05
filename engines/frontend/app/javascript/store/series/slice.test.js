import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/series/slice'
import {
  selectCurrentSeriesIndexEntry,
  selectSeriesIndexList,
  selectSeriesRefsByIds,
  selectSeriesRefsLoaded,
} from 'store/series/selectors'

const {
  addSeriesIndexEntry,
  assignSeriesIndex,
  assignSeriesRefs,
} = slice.actions

describe('series slice', () => {
  it('has an empty initial state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      seriesIndex: {},
      seriesRefs: {},
      refsLoaded: false,
    })
  })

  it('assigns index and refs', () => {
    let state = reducer(undefined, assignSeriesIndex([
      { id: 1, name: 'Earthsea' },
      { id: 2, name: 'Dune' },
    ]))
    state = reducer(state, addSeriesIndexEntry({
      id: 1,
      name: 'Earthsea',
      wikiUrl: 'https://wiki',
      genericLinks: [],
    }))
    state = reducer(state, assignSeriesRefs([
      { id: 1, name: 'Earthsea' },
      { id: 2, name: 'Dune' },
    ]))

    expect(state.seriesIndex[1].wikiUrl).toBe('https://wiki')
    expect(state.seriesRefs[2].name).toBe('Dune')
    expect(state.refsLoaded).toBe(true)
  })
})

describe('series selectors', () => {
  const state = {
    axis: { currentSeriesId: 1 },
    storeSeries: {
      seriesIndex: {
        1: { id: 1, name: 'Earthsea', wikiUrl: null, genericLinks: [] },
        2: { id: 2, name: 'Dune' },
      },
      seriesRefs: {
        1: { id: 1, name: 'Earthsea' },
        2: { id: 2, name: 'Dune' },
      },
      refsLoaded: true,
    },
  }

  it('reads series lists and current entry', () => {
    expect(selectSeriesIndexList()(state)).toHaveLength(2)
    expect(selectSeriesRefsByIds([2])(state)).toEqual([{ id: 2, name: 'Dune' }])
    expect(selectSeriesRefsLoaded()(state)).toBe(true)
    expect(selectCurrentSeriesIndexEntry()(state).name).toBe('Earthsea')
  })
})
