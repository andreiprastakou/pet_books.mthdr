import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import Pagination from 'components/Pagination'
import { renderWithProviders } from 'test/renderWithProviders'

const selectTotal = () => () => 100
const selectPage = () => () => 3
const selectPerPage = () => () => 10

describe('Pagination', () => {
  it('renders nothing when everything fits on one page', () => {
    const { container } = renderWithProviders(
      <Pagination
        selectPage={selectPage}
        selectPerPage={() => () => 100}
        selectTotal={selectTotal}
      />
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(
      <Pagination
        selectPage={selectPage}
        selectPerPage={selectPerPage}
        selectTotal={selectTotal}
      />,
      { urlStore: { routesReady: false } }
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('renders page links and switches page on click', async() => {
    const user = userEvent.setup()
    const switchToIndexPage = vi.fn()

    renderWithProviders(
      <Pagination
        selectPage={selectPage}
        selectPerPage={selectPerPage}
        selectTotal={selectTotal}
      />,
      {
        urlStore: {
          actions: { switchToIndexPage },
          routes: {
            indexPaginationPath: (page, perPage) => `/books?page=${page}&perPage=${perPage}`,
          },
        },
      }
    )

    expect(screen.getByText('3')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '2' })).toHaveAttribute('href', '/books?page=2&perPage=10')
    expect(screen.getByRole('link', { name: '4' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '1' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '10' })).toBeInTheDocument()

    await user.click(screen.getByRole('link', { name: '4' }))
    expect(switchToIndexPage).toHaveBeenCalledWith(4, 10)
  })
})
