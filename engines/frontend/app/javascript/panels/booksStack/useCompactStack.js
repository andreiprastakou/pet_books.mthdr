import { useCallback, useContext, useEffect, useMemo, useRef } from 'react'
import { useSelector } from 'react-redux'

import { selectCurrentBookId } from 'store/axis/selectors'
import { selectBookIds, selectBooksTotal } from 'store/booksList/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import {
  collectionIdsByWorkId,
  compactStackFromUrl,
  displayedWorksCount,
  hiddenSelectionFor,
} from 'panels/booksStack/collectedWorksInList'

const selectBooksIndex = state => state.storeBooks.booksIndex

const useStackBooks = () => ({
  bookIds: useSelector(selectBookIds()),
  booksIndex: useSelector(selectBooksIndex),
  booksTotal: useSelector(selectBooksTotal()),
  currentBookId: useSelector(selectCurrentBookId()),
})

const useRegisterCompactStackUrl = () => {
  const {
    actions: { addUrlAction, addUrlState },
    getActions,
    helpers: { buildRelativePath },
  } = useContext(UrlStoreContext)

  useEffect(() => {
    if (!addUrlState || !addUrlAction || !buildRelativePath) return () => null

    const removeState = addUrlState('compactStack', compactStackFromUrl)
    const removeAction = addUrlAction('setCompactStack', (compact, extra = {}) => {
      getActions().patch(buildRelativePath({
        params: { 'compact_stack': compact ? null : '0', ...extra },
      }))
    })
    return () => {
      removeState()
      removeAction()
    }
  }, [])
}

const useRevealHiddenSelection = ({ compactStack, getActions, hiddenSelection }) => {
  const requestedKey = useRef(null)

  useEffect(() => {
    if (!compactStack || !hiddenSelection) {
      requestedKey.current = null
      return
    }

    const { setCompactStack } = getActions()
    if (!setCompactStack) return

    const key = String(hiddenSelection.book_id)
    if (requestedKey.current === key) return

    requestedKey.current = key
    setCompactStack(true, hiddenSelection)
  }, [compactStack, getActions, hiddenSelection])
}

const useToggleCompactStack = ({ compactStack, getActions, hiddenSelection }) => (
  useCallback(() => {
    const { setCompactStack } = getActions()
    if (!setCompactStack) return

    const nextCompact = !compactStack
    const extra = nextCompact && hiddenSelection ? hiddenSelection : {}
    setCompactStack(nextCompact, extra)
  }, [compactStack, getActions, hiddenSelection])
)

const useCompactStack = () => {
  useRegisterCompactStackUrl()
  const { bookIds, booksIndex, booksTotal, currentBookId } = useStackBooks()
  const { getActions, pageState: { compactStack = true } } = useContext(UrlStoreContext)
  const collectionsByWorkId = useMemo(
    () => collectionIdsByWorkId(bookIds, booksIndex),
    [bookIds, booksIndex]
  )
  const hiddenSelection = useMemo(
    () => hiddenSelectionFor(collectionsByWorkId, currentBookId),
    [collectionsByWorkId, currentBookId]
  )
  const visibleBookIds = useMemo(() => (
    compactStack ? bookIds.filter(id => !collectionsByWorkId.has(id)) : bookIds
  ), [bookIds, collectionsByWorkId, compactStack])
  useRevealHiddenSelection({ compactStack, getActions, hiddenSelection })
  const toggleCompactStack = useToggleCompactStack({ compactStack, getActions, hiddenSelection })

  return {
    compactStack,
    currentBookId,
    nestedWorksShown: bookIds.some(id => collectionsByWorkId.has(id)),
    scrollEpoch: Number(compactStack),
    toggleCompactStack,
    visibleBookIds,
    worksCount: displayedWorksCount(bookIds, booksTotal, booksIndex),
  }
}

export default useCompactStack
