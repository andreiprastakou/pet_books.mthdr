import { addAuthorsIndexEntries } from 'store/authors/actions'
import { selectPage, selectPerPage, selectSortBy } from 'pages/authorsPage/selectors'
import { slice } from 'pages/authorsPage/slice'
import apiClient from 'store/authors/apiClient'

export const {
  assignAuthorIds,
  assignAuthorsTotal,
  assignSortBy,
  assignPage,
  assignPerPage,
} = slice.actions

export const fetchAuthorsIndex = () => (dispatch, getState) => {
  const state = getState()
  const query = {
    page: selectPage()(state),
    perPage: selectPerPage()(state),
    sortBy: selectSortBy()(state),
  }
  return apiClient.getAuthorsIndex(query).then(({ list, total }) => {
    dispatch(addAuthorsIndexEntries(list))
    dispatch(assignAuthorIds(list.map(author => author.id)))
    dispatch(assignAuthorsTotal(total))
  })
}
