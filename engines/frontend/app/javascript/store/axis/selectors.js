const localState = state => state.axis

export const selectCurrentAuthorId = () => state => localState(state).currentAuthorId

export const selectCurrentBookId = () => state => localState(state).currentBookId

export const selectCurrentTagId = () => state => localState(state).currentTagId
