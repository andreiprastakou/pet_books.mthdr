import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/coverDesigns/apiClient'
import CoverDesign from 'store/coverDesigns/api/CoverDesign'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('CoverDesign.parse', () => {
  it('maps snake_case API fields', () => {
    expect(CoverDesign.parse({
      id: 1,
      name: 'Classic',
      title_color: '#111',
      title_font: 'Serif',
      author_name_color: '#222',
      author_name_font: 'Sans',
      cover_image: '/cover.png',
    })).toEqual({
      id: 1,
      name: 'Classic',
      titleColor: '#111',
      titleFont: 'Serif',
      authorNameColor: '#222',
      authorNameFont: 'Sans',
      coverImage: '/cover.png',
    })
  })
})

describe('coverDesigns apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
  })

  it('fetches and parses cover designs', async() => {
    jQuery.ajax.mockResolvedValue([
      {
        id: 1,
        name: 'Classic',
        title_color: '#111',
        title_font: 'Serif',
        author_name_color: '#222',
        author_name_font: 'Sans',
        cover_image: '/cover.png',
      },
    ])

    const result = await apiClient.getCoverDesigns()

    expect(jQuery.ajax).toHaveBeenCalledWith({ url: '/api/cover_designs.json' })
    expect(result).toEqual([{
      id: 1,
      name: 'Classic',
      titleColor: '#111',
      titleFont: 'Serif',
      authorNameColor: '#222',
      authorNameFont: 'Sans',
      coverImage: '/cover.png',
    }])
  })
})
