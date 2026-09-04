import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/tags/slice'
import {
  selectCategories,
  selectCurrentTagIndexEntry,
  selectTagIndexEntry,
  selectTagNames,
  selectTagRef,
  selectTagsCategoriesIndex,
  selectTagsIndex,
  selectTagsRefs,
  selectTagsRefsByIds,
  selectTagsRefsLoaded,
} from 'store/tags/selectors'

const {
  addTagIndexEntry,
  addTagRef,
  assignCategories,
  assignTagsIndex,
  assignTagsRefs,
} = slice.actions

describe('tags slice', () => {
  it('has an empty unloaded initial state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      categories: {},
      tagsIndex: {},
      tagsCategoriesIndex: {},
      tagsRefs: {},
      refsLoaded: false,
    })
  })

  it('adds a single tag index entry', () => {
    const entry = { id: 1, name: 'fiction', categoryId: 10 }
    expect(reducer(undefined, addTagIndexEntry(entry)).tagsIndex).toEqual({ 1: entry })
  })

  it('assigns tags index and groups by category', () => {
    const entries = [
      { id: 1, name: 'fiction', categoryId: 10 },
      { id: 2, name: 'poetry', categoryId: 10 },
      { id: 3, name: 'science', categoryId: 20 },
    ]
    const state = reducer(undefined, assignTagsIndex(entries))

    expect(state.tagsIndex).toEqual({
      1: entries[0],
      2: entries[1],
      3: entries[2],
    })
    expect(state.tagsCategoriesIndex).toEqual({
      10: [entries[0], entries[1]],
      20: [entries[2]],
    })
  })

  it('adds a tag ref and assigns categories and refs', () => {
    const ref = { id: 1, name: 'fiction', categoryId: 10 }
    let state = reducer(undefined, addTagRef(ref))
    expect(state.tagsRefs).toEqual({ 1: ref })

    state = reducer(state, assignCategories([{ id: 10, name: 'Genre' }]))
    expect(state.categories).toEqual({ 10: { id: 10, name: 'Genre' } })

    state = reducer(state, assignTagsRefs([
      { id: 2, name: 'classic', categoryId: 10 },
    ]))
    expect(state.refsLoaded).toBe(true)
    expect(state.tagsRefs).toEqual({
      2: { id: 2, name: 'classic', categoryId: 10 },
    })
  })
})

describe('tags selectors', () => {
  const fiction = { id: 1, name: 'fiction', categoryId: 10 }
  const classic = { id: 2, name: 'classic', categoryId: 10 }
  const state = {
    axis: { currentTagId: 1 },
    storeTags: {
      categories: { 10: { id: 10, name: 'Genre' } },
      tagsIndex: { 1: fiction, 2: classic },
      tagsCategoriesIndex: { 10: [fiction, classic] },
      tagsRefs: { 1: fiction, 2: classic },
      refsLoaded: true,
    },
  }

  it('selects categories, index entries, refs, and names', () => {
    expect(selectCategories()(state)).toEqual([{ id: 10, name: 'Genre' }])
    expect(selectTagsIndex()(state)).toEqual(state.storeTags.tagsIndex)
    expect(selectTagIndexEntry(2)(state)).toEqual(classic)
    expect(selectTagsCategoriesIndex()(state)).toEqual({ 10: [fiction, classic] })
    expect(selectTagsRefs()(state)).toEqual([fiction, classic])
    expect(selectTagRef(1)(state)).toEqual(fiction)
    expect(selectTagsRefsByIds([1, 2])(state)).toEqual([fiction, classic])
    expect(selectTagNames([1, 2])(state)).toEqual(['fiction', 'classic'])
    expect(selectTagsRefsLoaded()(state)).toBe(true)
    expect(selectCurrentTagIndexEntry()(state)).toEqual(fiction)
  })
})
