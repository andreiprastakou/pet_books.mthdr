import { useEffect, useState } from 'react'
import { useLocation } from 'react-router-dom'

// Keep in step with $compact-max-width in frontend/layout.scss.
// The desktop floor is 900px; compact layout starts at 899px.
export const COMPACT_LAYOUT_MEDIA = '(max-width: 899px)'

const AUTHOR_PAGE_PATH = /^\/authors\/\d+\/?$/u
const AUTHORS_INDEX_PATH = /^\/authors\/?$/u
const TAGS_INDEX_PATH = /^\/tags\/?$/u
const TAG_PAGE_PATH = /^\/tags\/\d+\/?$/u
const SERIES_INDEX_PATH = /^\/series\/?$/u
const SERIES_PAGE_PATH = /^\/series\/\d+\/?$/u
const PUBLIC_LISTS_PAGE_PATH = /^\/public-lists\/\d+\/?$/u
const BOOKS_INDEX_PATH = /^\/books\/?$/u
const READS_PAGE_PATH = /^\/reads\/?$/u
const PIN_BOARD_PAGE_PATH = /^\/pins\/?$/u

export const isAuthorPagePath = pathname => AUTHOR_PAGE_PATH.test(pathname || '')

export const isAuthorsIndexPath = pathname => AUTHORS_INDEX_PATH.test(pathname || '')

export const isTagsIndexPath = pathname => TAGS_INDEX_PATH.test(pathname || '')

export const isTagPagePath = pathname => TAG_PAGE_PATH.test(pathname || '')

export const isSeriesIndexPath = pathname => SERIES_INDEX_PATH.test(pathname || '')

export const isSeriesPagePath = pathname => SERIES_PAGE_PATH.test(pathname || '')

export const isPublicListsPagePath = pathname => PUBLIC_LISTS_PAGE_PATH.test(pathname || '')

export const isBooksIndexPath = pathname => BOOKS_INDEX_PATH.test(pathname || '')

export const isReadsPagePath = pathname => READS_PAGE_PATH.test(pathname || '')

export const isPinBoardPagePath = pathname => PIN_BOARD_PAGE_PATH.test(pathname || '')

const compactLayoutPath = pathname =>
  isAuthorPagePath(pathname) ||
  isAuthorsIndexPath(pathname) ||
  isTagsIndexPath(pathname) ||
  isTagPagePath(pathname) ||
  isSeriesIndexPath(pathname) ||
  isSeriesPagePath(pathname) ||
  isPublicListsPagePath(pathname) ||
  isBooksIndexPath(pathname) ||
  isReadsPagePath(pathname) ||
  isPinBoardPagePath(pathname)

const narrowViewport = () => {
  if (typeof window.matchMedia !== 'function') return false

  return window.matchMedia(COMPACT_LAYOUT_MEDIA).matches
}

const subscribe = (media, update) => {
  if (typeof media.addEventListener === 'function') {
    media.addEventListener('change', update)
    return () => media.removeEventListener('change', update)
  }

  media.addListener(update)
  return () => media.removeListener(update)
}

// Missing matchMedia (jsdom) stays on the desktop layout.
const useCompactLayout = () => {
  const { pathname } = useLocation()
  const [narrow, setNarrow] = useState(narrowViewport)

  useEffect(() => {
    if (typeof window.matchMedia !== 'function') return () => setNarrow(false)

    const media = window.matchMedia(COMPACT_LAYOUT_MEDIA)
    const update = () => setNarrow(media.matches)

    update()
    return subscribe(media, update)
  }, [])

  return compactLayoutPath(pathname) && narrow
}

export default useCompactLayout
