import { useLayoutEffect, useRef } from 'react'

import useCompactLayout from 'hooks/useCompactLayout'

// A replaced record keeps the previous scroll offset on the same panel body.
// Move that body back to the top when the displayed record changes.
// In the compact layout the document is the scroller, and assigning
// scrollTop on a panel body that is not a scrollport jumps that page to the top.
const useScrollToTop = resetKey => {
  const ref = useRef(null)
  const compact = useCompactLayout()

  useLayoutEffect(() => {
    if (compact || !ref.current) return

    ref.current.scrollTop = 0
  }, [compact, resetKey])

  return ref
}

export default useScrollToTop
