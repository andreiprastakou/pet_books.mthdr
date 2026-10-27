import { useEffect, useState } from 'react'

// Keep in step with $compact-max-width in frontend/layout.scss.
// The desktop floor is 900px; compact layout starts at 899px.
export const COMPACT_LAYOUT_MEDIA = '(max-width: 899px)'

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
// Every frontend page uses this layout once the viewport is narrow.
const useCompactLayout = () => {
  const [narrow, setNarrow] = useState(narrowViewport)

  useEffect(() => {
    if (typeof window.matchMedia !== 'function') return () => setNarrow(false)

    const media = window.matchMedia(COMPACT_LAYOUT_MEDIA)
    const update = () => setNarrow(media.matches)

    update()
    return subscribe(media, update)
  }, [])

  return narrow
}

export default useCompactLayout
