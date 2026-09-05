import { slice } from 'store/series/slice'
import apiClient from 'store/series/apiClient'

export const {
  addSeriesIndexEntry,
  assignSeriesIndex,
  assignSeriesRefs,
} = slice.actions

export const fetchSeriesIndex = () => async dispatch => {
  const entries = await apiClient.getSeriesIndex()
  dispatch(assignSeriesIndex(entries))
}

export const fetchSeriesIndexEntry = id => async dispatch => {
  const entry = await apiClient.getSeriesIndexEntry(id)
  dispatch(addSeriesIndexEntry(entry))
}

export const fetchSeriesRefs = () => async dispatch => {
  const seriesRefs = await apiClient.getSeriesRefs()
  dispatch(assignSeriesRefs(seriesRefs))
}
