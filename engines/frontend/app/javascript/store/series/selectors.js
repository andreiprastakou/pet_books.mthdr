import pick from 'lodash/pick'
import { selectCurrentSeriesId } from 'store/axis/selectors'

const localState = state => state.storeSeries

export const selectSeriesIndex = () => state => localState(state).seriesIndex

export const selectSeriesIndexEntry = id => state => selectSeriesIndex()(state)[id]

export const selectSeriesIndexList = () => state => Object.values(localState(state).seriesIndex)

export const selectSeriesRefs = () => state => Object.values(localState(state).seriesRefs)

export const selectSeriesRef = id => state => localState(state).seriesRefs[id]

export const selectSeriesRefsByIds = ids => state => Object.values(pick(localState(state).seriesRefs, ids))

export const selectSeriesRefsLoaded = () => state => localState(state).refsLoaded

export const selectCurrentSeriesIndexEntry = () => state => {
  const id = selectCurrentSeriesId()(state)
  return selectSeriesIndex()(state)[id]
}
