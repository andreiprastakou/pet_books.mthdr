import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import { Card } from 'react-bootstrap'
import PropTypes from 'prop-types'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faEye } from '@fortawesome/free-solid-svg-icons/faEye'
import { faEyeSlash } from '@fortawesome/free-solid-svg-icons/faEyeSlash'

import { setRequestedBookId } from 'store/books/actions'
import BooksSpineStack from 'panels/booksStack/BooksSpineStack'
import SortingDropdown from 'panels/booksStack/SortingDropdown'
import useCompactStack from 'panels/booksStack/useCompactStack'
import UrlStoreContext from 'store/urlStore/Context'

const PANEL_ID = 'books-stack'

const StackHeader = ({ compactStack, nestedWorksShown, toggleCompactStack, worksCount }) => (
  <Card.Header className='panel--header'>
    <span>
      { 'All Works' }
    </span>

    { worksCount > 0 ? (
      <span className='books-spine-count-badge'>
        { worksCount }
      </span>
    ) : null }

    { nestedWorksShown ? (
      <button
        aria-label={compactStack ? 'Show books in collections' : 'Hide books in collections'}
        aria-pressed={compactStack}
        className='books-spine-compact-toggle'
        onClick={toggleCompactStack}
        type='button'
      >
        <FontAwesomeIcon icon={compactStack ? faEyeSlash : faEye} />
      </button>
    ) : null }

    <SortingDropdown />
  </Card.Header>
)

StackHeader.propTypes = {
  compactStack: PropTypes.bool.isRequired,
  nestedWorksShown: PropTypes.bool.isRequired,
  toggleCompactStack: PropTypes.func.isRequired,
  worksCount: PropTypes.number.isRequired,
}

const BooksListControls = () => {
  const dispatch = useDispatch()
  const {
    compactStack,
    currentBookId,
    nestedWorksShown,
    scrollEpoch,
    toggleCompactStack,
    visibleBookIds,
    worksCount,
  } = useCompactStack()
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
    const up = event.key === 'ArrowUp' || event.key === 'Up'
    const down = event.key === 'ArrowDown' || event.key === 'Down'
    const index = visibleBookIds.indexOf(currentBookId)
    if (!isActive || (!up && !down) || index < 0) return

    event.preventDefault()
    event.stopPropagation()
    const shift = up ? -1 : 1
    const target = (index + shift + visibleBookIds.length) % visibleBookIds.length
    dispatch(setRequestedBookId(visibleBookIds[target]))
  }, [currentBookId, dispatch, isActive, visibleBookIds])

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
      <StackHeader
        compactStack={compactStack}
        nestedWorksShown={nestedWorksShown}
        toggleCompactStack={toggleCompactStack}
        worksCount={worksCount}
      />

      <Card.Body className='panel--body'>
        <BooksSpineStack
          bookIds={visibleBookIds}
          isActive={isActive}
          scrollEpoch={scrollEpoch}
        />
      </Card.Body>
    </Card>
  )
}

export default BooksListControls
