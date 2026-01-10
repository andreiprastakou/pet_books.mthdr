const localState = state => state.booksListLinear

export const selectBookIds = () => state => localState(state).bookIds

export const selectBooksTotal = () => state => localState(state).booksTotal

export const selectFilter = () => state => localState(state).listFilter

export const selectSortBy = () => state => localState(state).sortBy

export const selectPage = () => state => localState(state).page

export const selectPerPage = () => state => localState(state).perPage
