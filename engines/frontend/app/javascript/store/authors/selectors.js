const localState = state => state.storeAuthors

export const selectAuthorFull = id => state => localState(state).authorsFull[id]

export const selectAuthorIndexEntry = id => state => localState(state).authorsIndex[id]

export const selectAuthorsIndex = () => state => Object.values(localState(state).authorsIndex)

export const selectAuthorsIndexEntriesByIds = ids => state => ids.map(id => localState(state).authorsIndex[id])

export const selectAuthorRef = id => state => localState(state).authorsRefs[id]

export const selectAuthorsRefs = () => state => Object.values(localState(state).authorsRefs)

export const selectAuthorsRefsLoaded = () => state => localState(state).refsLoaded

export const selectAuthorDefaultImageUrl = () => state => localState(state).defaultPhotoUrl
