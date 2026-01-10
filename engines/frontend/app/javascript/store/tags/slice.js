import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storeTags',
  initialState: {
    categories: {},
    tagsIndex: {},
    tagsCategoriesIndex: {},
    tagsRefs: {},
    refsLoaded: false,
  },
  reducers: {
    addTagIndexEntry: (state, action) => {
      const entry = action.payload
      state.tagsIndex[entry.id] = entry
    },

    assignTagsIndex: (state, action) => {
      const entries = action.payload
      state.tagsIndex = {}
      state.tagsCategoriesIndex = {}
      entries.forEach(entry => {
        state.tagsIndex[entry.id] = entry
        state.tagsCategoriesIndex[entry.categoryId] ||= []
        state.tagsCategoriesIndex[entry.categoryId].push(entry)
      })
    },

    addTagRef: (state, action) => {
      const entry = action.payload
      state.tagsRefs[entry.id] = entry
    },

    assignCategories: (state, action) => {
      const categories = action.payload
      state.categories = {}
      categories.forEach(category => {
        state.categories[category.id] = category
      })
    },

    assignTagsRefs: (state, action) => {
      const tagsRefs = action.payload
      state.tagsRefs = {}
      tagsRefs.forEach(tagRef => {
        state.tagsRefs[tagRef.id] = tagRef
      })
      state.refsLoaded = true
    },

    resetTagInCategories: (state, action) => {
      const tagIndexEntry = action.payload
      const entriesGrouped = Object.values(state.tagsCategoriesIndex)
      entriesGrouped.forEach(entries => {
        const index = entries.findIndex(tag => tag.id === tagIndexEntry.id)
        if (index < 0) return

        entries.splice(index, 1)
      })
      state.tagsCategoriesIndex[tagIndexEntry.categoryId] ||= []
      state.tagsCategoriesIndex[tagIndexEntry.categoryId].push(tagIndexEntry)
    }
  }
})

export default slice.reducer
