const localState = state => state.storeAuthors

export const selectAuthorFull = id => state => localState(state).authorsFull[id]

export const selectAuthorsIndexEntriesByIds = ids => state => ids.map(id => localState(state).authorsIndex[id])

export const selectAuthorsRefsByIds = ids => state => ids.map(id => localState(state).authorsRefs[id])

export const selectAuthorsRefsLoaded = () => state => localState(state).refsLoaded

export const selectAuthorDefaultImageUrl = () => state => localState(state).defaultPhotoUrl
