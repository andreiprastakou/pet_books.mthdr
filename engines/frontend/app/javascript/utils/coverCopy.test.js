import { describe, expect, it } from 'vitest'

import { FORMAT_NORMAL, FORMAT_SMALL } from 'utils/coverPalettes'
import { coverAuthorLine, coverTitle } from 'utils/coverCopy'

const anthology = [
  'Adrian Tchaikovsky', 'Hal Wilson', 'Christopher Allen', 'Liane Merciel',
  'Noah Van Nguyen', 'Nick Horth', 'Anna Stephens', 'Matt Keefe',
]

describe('coverCopy', () => {
  it('leaves a title that fits on the default cover unchanged', () => {
    const title = 'On the Shoulders of Giants and Other Stories'
    expect(coverTitle(title, { format: FORMAT_NORMAL, size: 'lg' })).toBe(title)
  })

  it('leaves a seventy-character title intact at the default size', () => {
    const title = 'N'.repeat(70)
    expect(coverTitle(title, { format: FORMAT_NORMAL, size: 'lg' })).toBe(title)
  })

  it('shortens a title that cannot fit the narrowest cover', () => {
    const displayed = coverTitle('N'.repeat(70), { format: FORMAT_NORMAL, size: 'xs' })
    expect(displayed.length).toBeLessThan(70)
    expect(displayed.endsWith('...')).toBe(true)
  })

  it('omits a byline that has too many or too-long names', () => {
    expect(coverAuthorLine(anthology, { format: FORMAT_NORMAL, size: 'lg' })).toBeNull()
    expect(coverAuthorLine(
      ['Christopher Allen Williamson', 'Liane Merciel-Something'],
      { format: FORMAT_SMALL, size: 'lg' }
    )).toBeNull()
  })

  it('keeps a short shared byline', () => {
    expect(coverAuthorLine(['Hal Wilson', 'Matt Keefe'], { format: FORMAT_NORMAL, size: 'lg' })).toEqual({
      text: 'Hal Wilson, Matt Keefe',
      tight: false,
    })
  })

  it('always keeps a single author and tightens a name that would leave the cover', () => {
    expect(coverAuthorLine(['Frank Herbert'], { format: FORMAT_NORMAL, size: 'lg' })).toEqual({
      text: 'Frank Herbert',
      tight: false,
    })

    const name = `Tchaikovsky${'E'.repeat(80)}`
    expect(coverAuthorLine([name], { format: FORMAT_NORMAL, size: 'lg' })).toEqual({
      text: name,
      tight: true,
    })
  })
})
