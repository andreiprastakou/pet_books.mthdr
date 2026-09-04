import React from 'react'
import { cleanup, render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it } from 'vitest'

import ExternalTextLink from 'components/ExternalTextLink'

afterEach(cleanup)

describe('ExternalTextLink', () => {
  it('renders a known resource label as an external link button', () => {
    render(
      <ExternalTextLink
        href='https://en.wikipedia.org/wiki/Example'
        resource='wikipedia'
      />
    )

    // react-bootstrap Button with href renders <a role="button">
    const link = screen.getByRole('button', { name: /wikipedia/iu })
    expect(link).toHaveAttribute('href', 'https://en.wikipedia.org/wiki/Example')
    expect(link).toHaveAttribute('target', '_blank')
    expect(link).toHaveAttribute('rel', 'noreferrer')
    expect(link).toHaveClass('external-link')
  })

  it('falls back to the raw resource name and accepts a custom class', () => {
    render(
      <ExternalTextLink
        className='custom-external'
        href='https://example.com'
        resource='blog'
      />
    )

    const link = screen.getByRole('button', { name: /blog/iu })
    expect(link).toHaveTextContent('blog')
    expect(link).toHaveClass('custom-external')
  })
})
