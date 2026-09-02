import PropTypes from 'prop-types'

// Mirrors $b-cover-sizes in app/assets/stylesheets/cover_designs.scss.
export const COVER_SIZES = {
  xs: { height: 150, width: 100 },
  sm: { height: 180, width: 120 },
  md: { height: 210, width: 140 },
  lg: { height: 240, width: 160 },
}

export const DEFAULT_COVER_SIZE = 'lg'
export const SMALLEST_COVER_SIZE = 'xs'

const SIZES_WIDEST_FIRST = ['lg', 'md', 'sm', 'xs']

export const coverSizeClass = size => `b-cover-size-${size}`

export const coverSizeType = PropTypes.oneOf(Object.keys(COVER_SIZES))

export const coverSizeForWidth = availableWidth => SIZES_WIDEST_FIRST.find(
  size => COVER_SIZES[size].width <= availableWidth
) || SMALLEST_COVER_SIZE
