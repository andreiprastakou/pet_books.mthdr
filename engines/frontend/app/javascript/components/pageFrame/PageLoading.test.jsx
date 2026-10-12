import React from 'react'
import { cleanup, render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it } from 'vitest'

import PageLoading from 'components/pageFrame/PageLoading'

afterEach(cleanup)

describe('PageLoading', () => {
  it('centers a spinner with an accessible loading status', () => {
    const { container } = render(<PageLoading />)

    expect(container.querySelector('.page-loading')).toBeInTheDocument()
    expect(container.querySelector('.page-loading-spinner.spinner-border')).toBeInTheDocument()
    expect(screen.getByRole('status')).toHaveTextContent('Loading')
  })
})
