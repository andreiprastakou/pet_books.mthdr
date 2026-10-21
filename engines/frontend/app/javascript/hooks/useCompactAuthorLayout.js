import { useEffect, useState } from 'react'
import { useLocation } from 'react-router-dom'

// Keep in step with $compact-max-width in frontend/layout.scss.
// The desktop floor is 900px; compact layout starts at 899px.
export const COMPACT_LAYOUT_MEDIA = '(max-width: 899px)'

const AUTHOR_PAGE_PATH = /^\/authors\/\d+\/?$/u

export const isAuthorPagePath = pathname => AUTHOR_PAGE_PATH.test(pathname || '')

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
const useCompactAuthorLayout = () => {
  const { pathname } = useLocation()
  const [narrow, setNarrow] = useState(narrowViewport)

  useEffect(() => {
    if (typeof window.matchMedia !== 'function') return () => setNarrow(false)

    const media = window.matchMedia(COMPACT_LAYOUT_MEDIA)
    const update = () => setNarrow(media.matches)

    update()
    return subscribe(media, update)
  }, [])

  return isAuthorPagePath(pathname) && narrow
}

export default useCompactAuthorLayout
