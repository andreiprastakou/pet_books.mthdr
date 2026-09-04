import React from 'react'
import { cleanup, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import ImageContainer from 'components/ImageContainer'

afterEach(cleanup)

describe('ImageContainer', () => {
  it('renders children with the cover background style', () => {
    const { container } = render(
      <ImageContainer
        classes='extra'
        url='/covers/1.jpg'
      >
        <span>
          { 'caption' }
        </span>
      </ImageContainer>
    )

    const el = container.querySelector('.image-container.extra')
    expect(el).toHaveStyle({
      backgroundImage: 'url(/covers/1.jpg)',
      backgroundSize: 'contain',
    })
    expect(screen.getByText('caption')).toBeInTheDocument()
  })

  it('forwards onClick', async() => {
    const user = userEvent.setup()
    const onClick = vi.fn()

    const { container } = render(
      <ImageContainer
        onClick={onClick}
        url='/covers/1.jpg'
      />
    )

    await user.click(container.querySelector('.image-container'))
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
