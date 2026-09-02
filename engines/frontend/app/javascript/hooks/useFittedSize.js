import { useLayoutEffect, useRef, useState } from 'react'

// Watches a container and reports the largest preset `sizeForWidth` offers for
// one of the `columns` slots the container lays out. `inset` is the horizontal
// space each slot spends on anything but the sized element itself. Attach the
// returned ref to an element without horizontal padding, so that its client
// width is the width actually available for the slots.
const useFittedSize = ({ sizeForWidth, columns = 1, gap = 0, inset = 0 }) => {
  const ref = useRef(null)
  const [size, setSize] = useState(() => sizeForWidth(Infinity))

  useLayoutEffect(() => {
    const element = ref.current
    if (!element) return () => false

    const update = () => {
      const slot = (element.clientWidth - (gap * (columns - 1))) / columns
      setSize(sizeForWidth(slot - inset))
    }
    const observer = new ResizeObserver(update)
    observer.observe(element)
    update()

    return () => observer.disconnect()
  }, [columns, gap, inset, sizeForWidth])

  return [ref, size]
}

export default useFittedSize
