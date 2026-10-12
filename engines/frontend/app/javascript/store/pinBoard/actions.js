import { slice } from 'store/pinBoard/slice'
import apiClient from 'store/pinBoard/apiClient'

export const { setPinBoard } = slice.actions

export const fetchPinBoard = () => async dispatch => {
  const board = await apiClient.getPinBoard()
  dispatch(setPinBoard(board))
}
