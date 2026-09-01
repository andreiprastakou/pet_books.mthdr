const localState = state => state.booksYears

export const selectYears = () => state => localState(state).years.slice()
