// What of a title and byline actually fits on a generated cover.
// Geometry matches $b-cover-sizes and the author band in cover_designs.scss.
// Keep in sync with CoverLayout (app/services/cover_layout.rb).
import { FORMAT_SMALL } from 'utils/coverPalettes'

export const TITLE_LENGTH_LONG = 25
const AUTHOR_MAX_LINES = 4
const MULTI_AUTHOR_MAX_LINES = 2
const AUTHOR_LINE_HEIGHT = 1.1
const TITLE_LINE_HEIGHT = 1.2
const AUTHOR_BAND_FUDGE = 2
const AUTHOR_GAP = 4
const AUTHOR_CHAR_EM = 0.62
const TITLE_CHAR_EM = 0.7
const OMISSION = '...'
const SMALL_SEPARATOR = 8

const SIZES = {
  xs: { width: 100, height: 150, padding: 6, smallPadding: 26, authorFont: 8, titleFontLong: 11, smallTextFont: 9 },
  sm: { width: 120, height: 180, padding: 8, smallPadding: 32, authorFont: 9, titleFontLong: 12, smallTextFont: 10 },
  md: { width: 140, height: 210, padding: 9, smallPadding: 38, authorFont: 9, titleFontLong: 14, smallTextFont: 11 },
  lg: { width: 160, height: 240, padding: 10, smallPadding: 45, authorFont: 10, titleFontLong: 16, smallTextFont: 12 },
}

const metricsFor = size => SIZES[size] || SIZES.lg

const authorBand = font => (font * AUTHOR_LINE_HEIGHT * AUTHOR_MAX_LINES) + AUTHOR_BAND_FUDGE

const textWidth = (metrics, small) => metrics.width - (metrics.padding * (small ? 4 : 2))

const charsPerLine = (width, font, em) => Math.max(Math.floor(width / (font * em)), 1)

const standardTitleHeight = metrics => {
  const inner = metrics.height - (metrics.padding * 2)
  return inner - authorBand(metrics.authorFont) - AUTHOR_GAP - (metrics.padding * 2)
}

const smallTitleHeight = metrics => {
  const inner = metrics.height - (metrics.smallPadding * 2)
  return inner - (metrics.padding * 2) - authorBand(metrics.smallTextFont) - SMALL_SEPARATOR
}

const titleLines = (metrics, small, font) => {
  const textHeight = small ? smallTitleHeight(metrics) : standardTitleHeight(metrics)
  return Math.max(Math.floor(textHeight / (font * TITLE_LINE_HEIGHT)), 1)
}

export const coverTitleMaxChars = (format, size = 'lg') => {
  const metrics = metricsFor(size)
  const small = format === FORMAT_SMALL
  const font = small ? metrics.smallTextFont : metrics.titleFontLong
  return titleLines(metrics, small, font) * charsPerLine(textWidth(metrics, small), font, TITLE_CHAR_EM)
}

const authorCharsPerLine = (format, size) => {
  const metrics = metricsFor(size)
  const small = format === FORMAT_SMALL
  const font = small ? metrics.smallTextFont : metrics.authorFont
  return charsPerLine(textWidth(metrics, small), font, AUTHOR_CHAR_EM)
}

const truncate = (text, max) => {
  if (text.length <= max) return text
  const budget = max - OMISSION.length
  if (budget <= 0) return OMISSION
  let slice = text.slice(0, budget)
  const cut = slice.lastIndexOf(' ')
  if (cut > budget / 2) slice = slice.slice(0, cut)
  return `${slice.trimEnd()}${OMISSION}`
}

export const coverTitle = (text, { format, size = 'lg' } = {}) => (
  truncate(text || '', coverTitleMaxChars(format, size))
)

// One author is always returned. Several names are returned only when they fit
// on two lines; otherwise the cover stays untitled by them.
// `tight` asks for the smaller byline face so one long name stays inside the band.
export const coverAuthorLine = (names, { format, size = 'lg' } = {}) => {
  const cleaned = (names || []).map(name => (name || '').trim()).filter(Boolean)
  if (cleaned.length === 0) return null

  const text = cleaned.join(', ')
  const perLine = authorCharsPerLine(format, size)
  if (cleaned.length === 1) return { text, tight: text.length > perLine * AUTHOR_MAX_LINES }
  if (text.length > perLine * MULTI_AUTHOR_MAX_LINES) return null
  return { text, tight: false }
}
