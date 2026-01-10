import { slice } from 'widgets/notifications/slice'

export const {
  addMessage,
  removeMessage
} = slice.actions

export const addSuccessMessage = message => dispatch => {
  dispatch(addMessage({ type: 'success', message }))
}

export const addErrorMessage = message => dispatch => {
  dispatch(addMessage({ type: 'danger', message }))
}
