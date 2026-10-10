import { useContext, useEffect, useRef } from 'react'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import UrlStoreContext from 'store/urlStore/Context'

export const includedWorkIdFromUrl = url => {
  const raw = url.queryParameter('included_work_id')
  const id = parseInt(raw, 10)
  return Number.isFinite(id) ? id : null
}

const includedWorkIsValid = (book, includedWorkId) => (
  book.format === 'collection' && (book.collectedWorkIds || []).includes(includedWorkId)
)

export const shouldClearIncludedWork = ({
  book,
  bookChanged,
  includedWorkChanged,
  includedWorkId,
}) => {
  if (!includedWorkId) return false

  const staleSelection = Boolean(book) && !includedWorkIsValid(book, includedWorkId)
  const bookChangedWithoutIncludedWork = bookChanged && !includedWorkChanged
  return bookChangedWithoutIncludedWork || staleSelection
}

const useRegisterIncludedWorkUrl = () => {
  const {
    actions: { addUrlAction, addUrlState },
    helpers: { buildRelativePath },
    getActions,
  } = useContext(UrlStoreContext)

  useEffect(() => {
    if (!addUrlState || !addUrlAction || !buildRelativePath) return () => null

    const removeState = addUrlState('includedWorkId', includedWorkIdFromUrl)
    const removeAction = addUrlAction('showIncludedWork', id => {
      getActions().patch(buildRelativePath({ params: { included_work_id: id } }))
    })

    return () => {
      removeState()
      removeAction()
    }
  }, [])
}

const useSyncIncludedWorkSelection = book => {
  const currentBookId = useSelector(selectCurrentBookId())
  const {
    getActions,
    pageState: { includedWorkId = null },
  } = useContext(UrlStoreContext)
  const previousBookId = useRef(null)
  const previousIncludedWorkId = useRef(null)

  useEffect(() => {
    const bookChanged = Boolean(previousBookId.current) && previousBookId.current !== currentBookId
    const includedWorkChanged = previousIncludedWorkId.current !== includedWorkId
    previousBookId.current = currentBookId
    previousIncludedWorkId.current = includedWorkId

    const { showIncludedWork } = getActions()
    if (!showIncludedWork) return
    if (shouldClearIncludedWork({ book, bookChanged, includedWorkChanged, includedWorkId }))
      showIncludedWork(null)
  }, [book, currentBookId, getActions, includedWorkId])

  return includedWorkId
}

const useIncludedWorkSelection = book => {
  useRegisterIncludedWorkUrl()
  return useSyncIncludedWorkSelection(book)
}

export default useIncludedWorkSelection
