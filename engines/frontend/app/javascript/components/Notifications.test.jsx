import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import Notifications from 'components/Notifications'
import { renderWithProviders } from 'test/renderWithProviders'

describe('Notifications', () => {
  it('renders nothing visible when there are no messages', () => {
    const { container } = renderWithProviders(<Notifications />)

    expect(container.querySelector('.notifications')).toBeInTheDocument()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })

  it('renders messages and dismisses them', async() => {
    const user = userEvent.setup()

    const { store } = renderWithProviders(<Notifications />, {
      preloadedState: {
        notifications: {
          messages: [
            { id: 1, type: 'success', message: 'Saved' },
            { id: 2, type: 'danger', message: 'Failed' },
          ],
        },
      },
    })

    expect(screen.getByText('Saved')).toBeInTheDocument()
    expect(screen.getByText('Failed')).toBeInTheDocument()

    const dismissButtons = screen.getAllByRole('button', { name: /close/iu })
    await user.click(dismissButtons[0])

    expect(store.getState().notifications.messages).toEqual([
      { id: 2, type: 'danger', message: 'Failed' },
    ])
    expect(screen.queryByText('Saved')).not.toBeInTheDocument()
  })
})
