import { slice } from 'store/coverDesigns/slice'
import apiClient from 'store/coverDesigns/apiClient'
import { selectCoverDesignsLoaded } from 'store/coverDesigns/selectors'

export const {
  assignCoverDesigns,
} = slice.actions

export const fetchCoverDesigns = () => async(dispatch, getState) => {
  if (selectCoverDesignsLoaded()(getState())) return

  const coverDesigns = await apiClient.getCoverDesigns()
  dispatch(assignCoverDesigns(coverDesigns))
}
