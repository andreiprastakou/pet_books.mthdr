import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import SelectedWork from 'panels/SelectedWork'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('panels/bookDetails/BookDetails', () => ({
  default: ({ bookId, header, onClose, reducedHeight, showCover = true }) => (
    <section data-testid={bookId ? `included-${bookId}` : 'selected-work'}>
      <h2>
        { header }
      </h2>

      <span>
        { showCover ? 'with-cover' : 'no-cover' }
      </span>

      <span>
        { reducedHeight ? 'compact' : 'full' }
      </span>

      { onClose ? (
        <button
          onClick={onClose}
          type='button'
        >
          { 'clear' }
        </button>
      ) : null }
    </section>
  ),
}))

describe('SelectedWork', () => {
  it('shows the current book on its own', () => {
    renderWithProviders(<SelectedWork header='Selected Work' />)

    expect(screen.getByTestId('selected-work')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Selected Work' })).toBeInTheDocument()
    expect(screen.getByText('with-cover')).toBeInTheDocument()
    expect(screen.getByText('full')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'clear' })).not.toBeInTheDocument()
  })

  it('splits the row for the included work and clears that selection', async() => {
    const user = userEvent.setup()
    const showIncludedWork = vi.fn()

    renderWithProviders(<SelectedWork header='Selected Work' />, {
      urlStore: {
        actions: { showIncludedWork },
        pageState: { includedWorkId: 8 },
      },
    })

    expect(screen.getByTestId('selected-work')).toHaveTextContent('no-cover')
    expect(screen.getByTestId('selected-work')).toHaveTextContent('compact')
    expect(screen.getByTestId('included-8')).toHaveTextContent('Selected included work')
    expect(screen.getByTestId('included-8')).toHaveTextContent('no-cover')
    expect(document.querySelector('.selected-works-split')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'clear' }))
    expect(showIncludedWork).toHaveBeenCalledWith(null)
  })
})
