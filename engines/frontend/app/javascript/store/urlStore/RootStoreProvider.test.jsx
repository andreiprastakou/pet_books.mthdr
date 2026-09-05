import React, { useCallback, useContext, useEffect } from 'react'
import { cleanup, render, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { afterEach, describe, expect, it } from 'vitest'

import UrlStoreContext from 'store/urlStore/Context'
import RootStoreProvider, { buildPath } from 'store/urlStore/RootStoreProvider'

afterEach(cleanup)

describe('buildPath', () => {
  it('joins path, query params, and hash', () => {
    expect(buildPath({ path: '/books', params: { page: 2 }, hash: '#top' }))
      .toBe('/books?page=2#top')
    expect(buildPath({ path: '/books', initialParams: '?page=1', params: { page: 2 } }))
      .toBe('/books?page=2')
  })
})

const PanelProbe = () => {
  const {
    pageState: { activePanelId, registeredPanelIds },
    actions: { registerPanel, unregisterPanel, activatePanel, deactivatePanel },
  } = useContext(UrlStoreContext)

  useEffect(() => {
    registerPanel('panel-a')
    registerPanel('panel-b')
  }, [registerPanel])

  const handleActivateA = useCallback(() => activatePanel('panel-a'), [activatePanel])
  const handleActivateB = useCallback(() => activatePanel('panel-b'), [activatePanel])
  const handleDeactivateB = useCallback(() => deactivatePanel('panel-b'), [deactivatePanel])
  const handleUnregisterB = useCallback(() => unregisterPanel('panel-b'), [unregisterPanel])

  return (
    <div>
      <div data-testid='registered'>
        { registeredPanelIds.join(',') }
      </div>

      <div data-testid='active'>
        { activePanelId || '' }
      </div>

      <button
        onClick={handleActivateA}
        type='button'
      >
        { 'activate-a' }
      </button>

      <button
        onClick={handleActivateB}
        type='button'
      >
        { 'activate-b' }
      </button>

      <button
        onClick={handleDeactivateB}
        type='button'
      >
        { 'deactivate-b' }
      </button>

      <button
        onClick={handleUnregisterB}
        type='button'
      >
        { 'unregister-b' }
      </button>
    </div>
  )
}

describe('RootStoreProvider panel focus', () => {
  it('registers, activates, deactivates, and unregisters panels', async() => {
    const user = userEvent.setup()

    const { findByTestId, getByRole, getByTestId } = render(
      <MemoryRouter>
        <RootStoreProvider>
          <PanelProbe />
        </RootStoreProvider>
      </MemoryRouter>
    )

    expect(await findByTestId('registered')).toHaveTextContent('panel-a,panel-b')

    await user.click(getByRole('button', { name: 'activate-a' }))
    await waitFor(() => expect(getByTestId('active')).toHaveTextContent('panel-a'))

    await user.click(getByRole('button', { name: 'activate-b' }))
    await waitFor(() => expect(getByTestId('active')).toHaveTextContent('panel-b'))

    await user.click(getByRole('button', { name: 'deactivate-b' }))
    await waitFor(() => expect(getByTestId('active')).toHaveTextContent(''))

    await user.click(getByRole('button', { name: 'activate-b' }))
    await user.click(getByRole('button', { name: 'unregister-b' }))
    await waitFor(() => {
      expect(getByTestId('registered')).toHaveTextContent('panel-a')
      expect(getByTestId('active')).toHaveTextContent('')
    })
  })
})
