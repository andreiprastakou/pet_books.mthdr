import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import InternalLink from 'components/InternalLink'
import { renderWithProviders } from 'test/renderWithProviders'

describe('InternalLink', () => {
  it('renders an internal link with the given href and class', () => {
    renderWithProviders(
      <InternalLink
        className='extra'
        href='/books/1'
      >
        { 'Open book' }
      </InternalLink>
    )

    const link = screen.getByRole('link', { name: 'Open book' })
    expect(link).toHaveAttribute('href', '/books/1')
    expect(link).toHaveClass('internal-link', 'extra')
  })

  it('navigates via goto on a plain left click', async() => {
    const user = userEvent.setup()
    const goto = vi.fn()

    const { urlStore } = renderWithProviders(
      <InternalLink href='/authors/2'>
        { 'Author' }
      </InternalLink>,
      { urlStore: { actions: { goto } } }
    )

    await user.click(screen.getByRole('link', { name: 'Author' }))
    expect(urlStore.actions.goto).toHaveBeenCalledWith('/authors/2')
  })

  it('does not navigate when default is prevented', async() => {
    const user = userEvent.setup()
    const goto = vi.fn()
    const onClick = event => event.preventDefault()

    renderWithProviders(
      <InternalLink
        href='/tags/3'
        onClick={onClick}
      >
        { 'Tag' }
      </InternalLink>,
      { urlStore: { actions: { goto } } }
    )

    await user.click(screen.getByRole('link', { name: 'Tag' }))
    expect(goto).not.toHaveBeenCalled()
  })
})
