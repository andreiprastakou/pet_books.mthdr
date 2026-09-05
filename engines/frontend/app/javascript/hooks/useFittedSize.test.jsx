import React, { useCallback } from 'react'
import PropTypes from 'prop-types'
import { cleanup, render } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import useFittedSize from 'hooks/useFittedSize'

const Probe = ({ columns, gap, inset, sizeForWidth, clientWidth }) => {
  const [ref, size] = useFittedSize({ columns, gap, inset, sizeForWidth })

  const assignRef = useCallback(node => {
    if (!node) return
    Object.defineProperty(node, 'clientWidth', {
      configurable: true,
      get: () => clientWidth,
    })
    ref.current = node
  }, [clientWidth, ref])

  return (
    <div
      data-size={size}
      ref={assignRef}
    />
  )
}

Probe.propTypes = {
  clientWidth: PropTypes.number.isRequired,
  columns: PropTypes.number.isRequired,
  gap: PropTypes.number.isRequired,
  inset: PropTypes.number.isRequired,
  sizeForWidth: PropTypes.func.isRequired,
}

describe('useFittedSize', () => {
  let observe = null
  let disconnect = null

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
