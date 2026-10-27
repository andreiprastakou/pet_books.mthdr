import React, { useCallback, useContext } from 'react'
import PropTypes from 'prop-types'

import BookDetails from 'panels/bookDetails/BookDetails'
import UrlStoreContext from 'store/urlStore/Context'

const SelectedIncludedWork = ({ includedWorkId, onClose }) => (
  <BookDetails
    bookId={includedWorkId}
    header='Selected included work'
    onClose={onClose}
    reducedHeight
    showCover={false}
  />
)

SelectedIncludedWork.propTypes = {
  includedWorkId: PropTypes.number.isRequired,
  onClose: PropTypes.func.isRequired,
}

const SelectedWork = ({ header = null, included = 'inline' }) => {
  const {
    actions: { showIncludedWork },
    pageState: { includedWorkId = null },
  } = useContext(UrlStoreContext)
  const clearIncludedWork = useCallback(() => {
    if (showIncludedWork) showIncludedWork(null)
  }, [showIncludedWork])

  if (included === 'only') {
    if (!includedWorkId) return null

    return (
      <SelectedIncludedWork
        includedWorkId={includedWorkId}
        onClose={clearIncludedWork}
      />
    )
  }

  if (!includedWorkId) return (
    <BookDetails header={header} />
  )

  const collection = (
    <BookDetails
      header={header}
      reducedHeight
      showCover={false}
    />
  )

  if (included === 'omit') return collection

  return (
    <div className='selected-works-split'>
      <div className='selected-works-split-pane'>
        { collection }
      </div>

      <div className='selected-works-split-pane'>
        <SelectedIncludedWork
          includedWorkId={includedWorkId}
          onClose={clearIncludedWork}
        />
      </div>
    </div>
  )
}

SelectedWork.propTypes = {
  header: PropTypes.node,
  included: PropTypes.oneOf(['inline', 'omit', 'only']),
}

export default SelectedWork
