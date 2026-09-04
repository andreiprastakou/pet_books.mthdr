import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import SortingDropdown from 'components/SortingDropdown'
import { renderWithProviders } from 'test/renderWithProviders'

const selectSortBy = () => () => 'title'

describe('SortingDropdown', () => {
  it('shows the current sort and switches on option click', async() => {
    const user = userEvent.setup()
    const switchToIndexSort = vi.fn()

    renderWithProviders(
      <SortingDropdown
        selectSortBy={selectSortBy}
        sortOptions={['title', 'year', 'author']}
      />,
      { urlStore: { actions: { switchToIndexSort } } }
    )

    expect(screen.getByRole('button', { name: /Sort by: title/u })).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: /Sort by: title/u }))
    await user.click(screen.getByRole('button', { name: 'year' }))

    expect(switchToIndexSort).toHaveBeenCalledWith('year')
  })
})
