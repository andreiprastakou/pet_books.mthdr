import { slice } from 'store/coverDesigns/slice'
import apiClient from 'store/coverDesigns/apiClient'

export const {
  assignCoverDesigns,
} = slice.actions

export const fetchCoverDesigns = () => async dispatch => {
  const coverDesigns = await apiClient.getCoverDesigns()
  dispatch(assignCoverDesigns(coverDesigns))
}
