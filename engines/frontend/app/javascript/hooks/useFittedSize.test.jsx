import React from 'react'
import { cleanup, render } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import useFittedSize from 'hooks/useFittedSize'

const Probe = ({ columns, gap, inset, sizeForWidth, clientWidth }) => {
  const [ref, size] = useFittedSize({ columns, gap, inset, sizeForWidth })

  return (
    <div
      data-size={size}
      ref={node => {
        if (!node) return
        Object.defineProperty(node, 'clientWidth', {
          configurable: true,
          get: () => clientWidth,
        })
        ref.current = node
      }}
    />
  )
}

describe('useFittedSize', () => {
  let observe
  let disconnect

  beforeEach(() => {
    observe = vi.fn()
    disconnect = vi.fn()
    vi.stubGlobal('ResizeObserver', vi.fn(function ResizeObserver(callback) {
      this.observe = element => {
        observe(element)
        callback()
      }
      this.disconnect = disconnect
    }))
  })

  afterEach(() => {
    cleanup()
    vi.unstubAllGlobals()
  })

  it('reports sizeForWidth based on fitted slot width', () => {
    const sizeForWidth = vi.fn(width => (width === Infinity ? 'lg' : 'sm'))

    const { container, rerender } = render(
      <Probe
        clientWidth={450}
        columns={4}
        gap={10}
        inset={10}
        sizeForWidth={sizeForWidth}
      />
    )

    // First render uses Infinity before the layout effect attaches the node.
    expect(sizeForWidth).toHaveBeenCalledWith(Infinity)

    // Force layout effect again now that the ref callback has set clientWidth.
    rerender(
      <Probe
        clientWidth={450}
        columns={4}
        gap={10}
        inset={10}
        sizeForWidth={sizeForWidth}
      />
    )

    // slot = (450 - 30) / 4 = 105; sizeForWidth(105 - 10)
    expect(sizeForWidth).toHaveBeenCalledWith(95)
    expect(container.firstChild).toHaveAttribute('data-size', 'sm')
    expect(observe).toHaveBeenCalled()
  })
})
