import React from 'react'
import { cleanup, render } from '@testing-library/react'
import { afterEach, describe, expect, it } from 'vitest'

import BookPlaceholder from 'components/BookPlaceholder'
import { DEFAULT_COVER_SIZE } from 'utils/coverSizes'

afterEach(cleanup)

describe('BookPlaceholder', () => {
  it('renders a loading placeholder with the default cover size', () => {
    const { container } = render(<BookPlaceholder id={42} />)

    const placeholder = container.querySelector('.book-case.placeholder')
    expect(placeholder).toHaveClass(`b-cover-size-${DEFAULT_COVER_SIZE}`)
    expect(placeholder).toHaveAttribute('title', 'ID=42')
    expect(container.querySelector('.placeholder-spinner.spinner-border')).toBeInTheDocument()
  })

  it('applies a custom size and inline style', () => {
    const { container } = render(
      <BookPlaceholder
        id={7}
        size='sm'
        style={{ opacity: 0.5 }}
      />
    )

    const placeholder = container.querySelector('.book-case.placeholder')
    expect(placeholder).toHaveClass('b-cover-size-sm')
    expect(placeholder).toHaveStyle({ opacity: '0.5' })
  })
})
