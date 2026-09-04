import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import TagsList from 'panels/tagsList/TagsList'
import { renderWithProviders } from 'test/renderWithProviders'

const tagsState = {
  categories: {
    1: { id: 1, name: 'Genre' },
    2: { id: 2, name: 'Theme' },
  },
  refsLoaded: true,
  tagsCategoriesIndex: {
    1: [
      { id: 11, name: 'fiction', categoryId: 1, connectionsCount: 3 },
      { id: 12, name: 'poetry', categoryId: 1, connectionsCount: 0 },
    ],
    2: [
      { id: 21, name: 'war', categoryId: 2, connectionsCount: 1 },
    ],
  },
  tagsIndex: {},
  tagsRefs: {
    11: { id: 11, name: 'fiction' },
    12: { id: 12, name: 'poetry' },
    21: { id: 21, name: 'war' },
  },
}

describe('TagsList', () => {
  it('shows the filtered count and connection postfix', () => {
    renderWithProviders(<TagsList />, {
      preloadedState: { storeTags: tagsState },
    })

    expect(screen.getByText('All Tags')).toBeInTheDocument()
    expect(screen.getByText('3')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '#fiction' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '#fiction' }).parentElement).toHaveTextContent('(3)')
  })

  it('filters by name and category', async() => {
    const user = userEvent.setup()

    renderWithProviders(<TagsList />, {
      preloadedState: { storeTags: tagsState },
    })

    await user.type(screen.getByLabelText('Filter tags by name'), 'war')
    expect(screen.getByText('1')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '#war' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: '#fiction' })).not.toBeInTheDocument()

    await user.clear(screen.getByLabelText('Filter tags by name'))
    await user.click(screen.getByRole('button', { name: 'All categories' }))
    await user.click(screen.getByRole('button', { name: 'Genre' }))

    expect(screen.getByText('2')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '#fiction' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: '#war' })).not.toBeInTheDocument()
  })
})
