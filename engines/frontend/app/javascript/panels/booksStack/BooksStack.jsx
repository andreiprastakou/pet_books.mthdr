import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Card } from 'react-bootstrap'

import { selectBooksTotal } from 'store/booksList/selectors'
import { shiftSelection } from 'store/booksList/actions'
import BooksSpineStack from 'panels/booksStack/BooksSpineStack'
import SortingDropdown from 'panels/booksStack/SortingDropdown'
import UrlStoreContext from 'store/urlStore/Context'

const PANEL_ID = 'books-stack'

const BooksListControls = () => {
  const dispatch = useDispatch()
  const totalCount = useSelector(selectBooksTotal())
  const ref = useRef(null)
  const hasActivated = useRef(false)
  const {
    pageState: { activePanelId, registeredPanelIds },
    actions: { activatePanel, deactivatePanel, registerPanel, unregisterPanel },
  } = useContext(UrlStoreContext)
  const isActive = activePanelId === PANEL_ID

  useEffect(() => {
    registerPanel(PANEL_ID)

    return () => unregisterPanel(PANEL_ID)
  }, [])

  useEffect(() => {
    if (hasActivated.current || !registeredPanelIds.includes(PANEL_ID)) return
    hasActivated.current = true
    activatePanel(PANEL_ID)
    ref.current?.focus()
  }, [activatePanel, registeredPanelIds])

  useEffect(() => {
    const handleOutsideInteraction = event => {
      if (!ref.current?.contains(event.target))
        deactivatePanel(PANEL_ID)
    }

    document.addEventListener('focusin', handleOutsideInteraction)
    document.addEventListener('click', handleOutsideInteraction)
    return () => {
      document.removeEventListener('focusin', handleOutsideInteraction)
      document.removeEventListener('click', handleOutsideInteraction)
    }
  }, [])

  const handleClick = useCallback(event => {
    activatePanel(PANEL_ID)

    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl) ref.current?.focus()
  }, [activatePanel])

  const handleKeyDown = useCallback(event => {
    if (!isActive) return

    if (event.key === 'ArrowUp' || event.key === 'Up') {
      event.preventDefault()
      event.stopPropagation()
      dispatch(shiftSelection(-1))
    } else if (event.key === 'ArrowDown' || event.key === 'Down') {
      event.preventDefault()
      event.stopPropagation()
      dispatch(shiftSelection(+1))
    }
  }, [dispatch, isActive])

  return (
    <Card
      aria-label='Books'
      className={`panel--books-stack panel--widget ${
        isActive ? 'active' : ''
      }`}
      id={PANEL_ID}
      onClick={handleClick}
      onKeyDown={handleKeyDown}
      ref={ref}
      tabIndex={0}
    >
      <Card.Header className='panel--header'>
        <span>
          { 'All Works' }
        </span>

        { totalCount > 0 ? (
          <span className='books-spine-count-badge'>
            { totalCount }
          </span>
        ) : null }

        <SortingDropdown />
      </Card.Header>

      <Card.Body className='panel--body'>
        <BooksSpineStack isActive={isActive} />
      </Card.Body>
    </Card>
  )
}

export default BooksListControls
