import PropTypes from 'prop-types'

// Mirrors $author-sizes in frontend/panels/authors-list.scss.
export const AUTHOR_SIZES = {
  sm: { thumb: 100 },
  lg: { thumb: 130 },
}

export const DEFAULT_AUTHOR_SIZE = 'lg'
export const SMALLEST_AUTHOR_SIZE = 'sm'

const SIZES_WIDEST_FIRST = ['lg', 'sm']

export const authorSizeClass = size => `author-size-${size}`

export const authorSizeType = PropTypes.oneOf(Object.keys(AUTHOR_SIZES))

export const authorSizeForWidth = availableWidth => SIZES_WIDEST_FIRST.find(
  size => AUTHOR_SIZES[size].thumb <= availableWidth
) || SMALLEST_AUTHOR_SIZE
