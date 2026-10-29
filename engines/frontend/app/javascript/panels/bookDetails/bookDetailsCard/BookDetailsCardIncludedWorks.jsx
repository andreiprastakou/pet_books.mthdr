import React, { useMemo } from 'react'
import { shallowEqual, useSelector } from 'react-redux'
import PropTypes from 'prop-types'
import shuffle from 'lodash/shuffle'

import InternalLink from 'components/InternalLink'
import { selectAuthorsRefsByIds } from 'store/authors/selectors'

const authorNamesLabel = (authorIds, authorsById) => {
  const names = (authorIds || [])
    .map(id => authorsById[id]?.fullname)
    .filter(Boolean)

  return names.length > 0 ? names.join(', ') : 'Unknown Author'
}

const workLabel = (work, authorsById, showAuthors) => {
  const base = `${work.title} (${work.year})`
  if (!showAuthors) return base

  return `${base} by ${authorNamesLabel(work.authorIds, authorsById)}`
}

const BookDetailsCardIncludedWorks = ({ bookPagePath, showAuthors, workIds }) => {
  const shuffledIds = useMemo(() => shuffle([...workIds]), [workIds])
  const booksIndex = useSelector(state => state.storeBooks.booksIndex)
  const works = shuffledIds.map(id => booksIndex[id]).filter(Boolean)
  const authorIds = showAuthors
    ? [...new Set(works.flatMap(work => work.authorIds || []))]
    : []
  const authorRefs = useSelector(selectAuthorsRefsByIds(authorIds), shallowEqual)
  const authorsById = useMemo(
    () => Object.fromEntries(authorRefs.filter(Boolean).map(ref => [ref.id, ref])),
    [authorRefs]
  )

  if (!works.length) return null

  return (
    <div className='book-details-panel-included-works'>
      <div className='book-details-panel-included-works-label'>
        Included works:
      </div>

      <ul>
        { works.map(work => (
          <li key={work.id}>
            <InternalLink href={bookPagePath(work.id)}>
              { workLabel(work, authorsById, showAuthors) }
            </InternalLink>
          </li>
        )) }
      </ul>
    </div>
  )
}

BookDetailsCardIncludedWorks.propTypes = {
  bookPagePath: PropTypes.func.isRequired,
  showAuthors: PropTypes.bool.isRequired,
  workIds: PropTypes.arrayOf(PropTypes.number).isRequired,
}

export default BookDetailsCardIncludedWorks
