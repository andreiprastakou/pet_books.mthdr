import { slice } from 'store/pinBoard/slice'
import apiClient from 'store/pinBoard/apiClient'

export const { setPinBoard } = slice.actions

export const fetchPinBoard = code => async dispatch => {
  const board = await apiClient.getPinBoard(code)
  dispatch(setPinBoard(board))
}
