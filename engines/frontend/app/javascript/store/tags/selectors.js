import { pick } from 'lodash'
import { selectCurrentTagId } from 'store/axis/selectors'

const BOOKMARK = 'BookmarkedByA'
const READ = 'ReadByA'

const localState = state => state.storeTags

export const selectCategories = () => state => Object.values(localState(state).categories)

export const selectCategory = id => state => localState(state).categories[id]

export const selectTagsIndex = () => state => localState(state).tagsIndex

export const selectTagIndexEntry = id => state => selectTagsIndex()(state)[id]

export const selectTagsCategoriesIndex = () => state => localState(state).tagsCategoriesIndex

export const selectTagsRefs = () => state => Object.values(localState(state).tagsRefs)

export const selectTagRef = id => state => localState(state).tagsRefs[id]

export const selectTagBookmark = () => () => BOOKMARK

export const selectTagIdBookmark = () => state => selectTagsRefs()(state).find(tag => tag.name === BOOKMARK)?.id

export const selectTagRead = () => () => READ

export const selectTagIdRead = () => state => selectTagsRefs()(state).find(tag => tag.name === READ)?.id

export const selectTagNames = ids => state => selectTagsRefsByIds(ids)(state).map(tag => tag.name)

export const selectTagsRefsByIds = ids => state => Object.values(pick(localState(state).tagsRefs, ids))

export const selectVisibleTags = tags => state => {
  const tagBookmark = selectTagBookmark()(state)
  const tagRead = selectTagRead()(state)
  return tags.filter(tag => ![tagBookmark, tagRead].includes(tag.name))
}

export const selectTagsRefsLoaded = () => state => localState(state).refsLoaded

export const selectCurrentTagIndexEntry = () => state => {
  const id = selectCurrentTagId()(state)
  return selectTagsIndex()(state)[id]
}
