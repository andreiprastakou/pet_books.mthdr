import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import TagBadge from 'components/TagBadge'
import { renderWithProviders } from 'test/renderWithProviders'

const tagRef = { id: 11, name: 'fiction' }

const Postfix = () => (
  <span>
    { 'postfix' }
  </span>
)

describe('TagBadge', () => {
  it('renders nothing when the tag ref is missing', () => {
    const { container } = renderWithProviders(
      <TagBadge
        id={11}
        text='fiction'
      />
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(
      <TagBadge
        id={11}
        text='fiction'
      />,
      {
        preloadedState: {
          storeTags: {
            categories: {},
            refsLoaded: true,
            tagsCategoriesIndex: {},
            tagsIndex: {},
            tagsRefs: { 11: tagRef },
          },
        },
        urlStore: { routesReady: false },
      }
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('links to the tag page and supports postfix / onClick', async() => {
    const user = userEvent.setup()
    const onClick = vi.fn()

    renderWithProviders(
      <TagBadge
        classes='extra'
        id={11}
        onClick={onClick}
        renderPostfix={Postfix}
        text='fiction'
      />,
      {
        preloadedState: {
          storeTags: {
            categories: {},
            refsLoaded: true,
            tagsCategoriesIndex: {},
            tagsIndex: {},
            tagsRefs: { 11: tagRef },
          },
        },
      }
    )

    const link = screen.getByRole('link', { name: '#fiction' })
    expect(link).toHaveAttribute('href', '/tags/11')
    expect(link.closest('.tag-badge')).toHaveClass('extra')
    expect(screen.getByText('postfix')).toBeInTheDocument()

    await user.click(link)
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
