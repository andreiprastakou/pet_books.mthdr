import { selectAuthorsIndexEntriesByIds } from 'store/authors/selectors'

const localState = state => state.authorsPage

export const selectSortedAuthors = () => state => {
  const ids = selectAuthorIds()(state)
  return selectAuthorsIndexEntriesByIds(ids)(state)
}

export const selectAuthorIds = () => state => localState(state).authorIds

export const selectAuthorsTotal = () => state => localState(state).authorsTotal

export const selectSortBy = () => state => localState(state).sortBy

export const selectPage = () => state => localState(state).page

export const selectPerPage = () => state => localState(state).perPage
