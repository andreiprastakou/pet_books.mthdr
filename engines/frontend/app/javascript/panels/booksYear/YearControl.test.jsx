import React from 'react'
import { cleanup, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

vi.mock('rsuite', () => ({
  Slider: () => null,
}))

vi.mock('rsuite/Slider/styles/index.css', () => ({}))

import YearControl from 'panels/booksYear/YearControl'

afterEach(cleanup)

describe('YearControl', () => {
  it('renders nothing when there are no years', () => {
    const { container } = render(
      <YearControl
        onChange={vi.fn()}
        value={null}
        years={[]}
      />
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('moves to next and previous years', async() => {
    const user = userEvent.setup()
    const onChange = vi.fn()

    render(
      <YearControl
        onChange={onChange}
        value={2000}
        years={[1990, 2000, 2010]}
      />
    )

    await user.click(screen.getByRole('button', { name: 'Next available year' }))
    expect(onChange).toHaveBeenCalledWith(2010)

    await user.click(screen.getByRole('button', { name: 'Previous available year' }))
    expect(onChange).toHaveBeenCalledWith(1990)
  })

  it('commits a valid year and reverts an invalid one on blur', async() => {
    const user = userEvent.setup()
    const onChange = vi.fn()

    render(
      <YearControl
        onChange={onChange}
        value={2000}
        years={[1990, 2000, 2010]}
      />
    )

    const input = screen.getByLabelText('Selected year')
    await user.clear(input)
    await user.type(input, '2010')
    await user.tab()
    expect(onChange).toHaveBeenCalledWith(2010)

    onChange.mockClear()
    await user.clear(input)
    await user.type(input, '1999')
    await user.tab()
    expect(onChange).not.toHaveBeenCalled()
    expect(input).toHaveValue('2000')
  })
})
