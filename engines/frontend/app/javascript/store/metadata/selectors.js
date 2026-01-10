const localState = state => state.metadata

export const selectPageIsLoading = () => state => localState(state).pageIsLoading
