import pick from 'lodash/pick'
import { selectCurrentTagId } from 'store/axis/selectors'

const localState = state => state.storeTags

export const selectCategories = () => state => Object.values(localState(state).categories)

export const selectTagsIndex = () => state => localState(state).tagsIndex

export const selectTagIndexEntry = id => state => selectTagsIndex()(state)[id]

export const selectTagsCategoriesIndex = () => state => localState(state).tagsCategoriesIndex

export const selectTagsRefs = () => state => Object.values(localState(state).tagsRefs)

export const selectTagRef = id => state => localState(state).tagsRefs[id]

export const selectTagNames = ids => state => selectTagsRefsByIds(ids)(state).map(tag => tag.name)

export const selectTagsRefsByIds = ids => state => Object.values(pick(localState(state).tagsRefs, ids))

export const selectTagsRefsLoaded = () => state => localState(state).refsLoaded

export const selectCurrentTagIndexEntry = () => state => {
  const id = selectCurrentTagId()(state)
  return selectTagsIndex()(state)[id]
}
