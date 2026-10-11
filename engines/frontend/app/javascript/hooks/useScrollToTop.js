import { useLayoutEffect, useRef } from 'react'

// A replaced record keeps the previous scroll offset on the same panel body.
// Move that body back to the top when the displayed record changes.
const useScrollToTop = resetKey => {
  const ref = useRef(null)

  useLayoutEffect(() => {
    if (ref.current) ref.current.scrollTop = 0
  }, [resetKey])

  return ref
}

export default useScrollToTop
