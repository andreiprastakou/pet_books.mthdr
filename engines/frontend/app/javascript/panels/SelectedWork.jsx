import React, { useCallback, useContext } from 'react'
import PropTypes from 'prop-types'

import BookDetails from 'panels/bookDetails/BookDetails'
import UrlStoreContext from 'store/urlStore/Context'

const SelectedWork = ({ header = null }) => {
  const {
    actions: { showIncludedWork },
    pageState: { includedWorkId = null },
  } = useContext(UrlStoreContext)
  const clearIncludedWork = useCallback(() => {
    if (showIncludedWork) showIncludedWork(null)
  }, [showIncludedWork])

  if (!includedWorkId) return (
    <BookDetails header={header} />
  )

  return (
    <div className='selected-works-split'>
      <div className='selected-works-split-pane'>
        <BookDetails
          header={header}
          reducedHeight
          showCover={false}
        />
      </div>

      <div className='selected-works-split-pane'>
        <BookDetails
          bookId={includedWorkId}
          header='Selected included work'
          onClose={clearIncludedWork}
          reducedHeight
          showCover={false}
        />
      </div>
    </div>
  )
}

SelectedWork.propTypes = {
  header: PropTypes.node,
}

export default SelectedWork
