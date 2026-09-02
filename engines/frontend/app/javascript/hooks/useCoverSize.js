import { useLayoutEffect, useRef, useState } from 'react'

import { DEFAULT_COVER_SIZE, coverSizeForWidth } from 'utils/coverSizes'

// Watches a container and reports the widest cover preset that still fits one
// of the `columns` slots the container lays out. `inset` is the horizontal
// space each slot spends on anything but the cover itself. Attach the returned
// ref to an element without horizontal padding, so its client width is usable.
const useCoverSize = ({ columns = 1, gap = 0, inset = 0 } = {}) => {
  const ref = useRef(null)
  const [size, setSize] = useState(DEFAULT_COVER_SIZE)

  useLayoutEffect(() => {
    const element = ref.current
    if (!element) return () => false

    const update = () => {
      const slot = (element.clientWidth - (gap * (columns - 1))) / columns
      setSize(coverSizeForWidth(slot - inset))
    }
    const observer = new ResizeObserver(update)
    observer.observe(element)
    update()

    return () => observer.disconnect()
  }, [columns, gap, inset])

  return [ref, size]
}

export default useCoverSize
