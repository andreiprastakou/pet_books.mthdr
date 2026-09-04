import React from 'react'
import { cleanup, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import PublicListIntro from 'panels/publicListIntro/ListIntro'

afterEach(cleanup)

const listType = {
  name: 'Awards',
  wiki_url: 'https://en.wikipedia.org/wiki/Awards',
  generic_links: [{ name: 'official', url: 'https://example.com/awards' }],
  public_lists: [
    { id: 1, year: 2020 },
    { id: 2, year: 2021 },
  ],
}

describe('PublicListIntro', () => {
  it('renders type links and selected list links', () => {
    render(
      <PublicListIntro
        listType={listType}
        selectedList={{
          year: 2021,
          generic_links: [{ name: 'blog', url: 'https://example.com/2021' }],
        }}
        selectedListId={2}
        setSelectedListId={vi.fn()}
      />
    )

    expect(screen.getByText('Public lists/ Awards')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /wikipedia/iu })).toHaveAttribute(
      'href',
      'https://en.wikipedia.org/wiki/Awards'
    )
    expect(screen.getByRole('button', { name: /official/iu })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /2021 blog/iu })).toHaveAttribute(
      'href',
      'https://example.com/2021'
    )
  })

  it('changes the selected list id from the year select', async() => {
    const user = userEvent.setup()
    const setSelectedListId = vi.fn()

    render(
      <PublicListIntro
        listType={listType}
        selectedList={null}
        selectedListId={1}
        setSelectedListId={setSelectedListId}
      />
    )

    await user.selectOptions(screen.getByLabelText('Public list'), '2')
    expect(setSelectedListId).toHaveBeenCalledWith(2)
  })
})
