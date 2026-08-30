import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Card } from 'react-bootstrap'

import { selectBooksTotal } from 'widgets/booksListLinear/selectors'
import { shiftSelection } from 'widgets/booksListLinear/actions'
import BooksSpineStack from 'sidebar/booksStack/BooksSpineStack'
import SortingDropdown from 'sidebar/booksStack/SortingDropdown'
import UrlStoreContext from 'store/urlStore/Context'

const WIDGET_ID = 'books-stack'

const BooksListControls = () => {
  const dispatch = useDispatch()
  const totalCount = useSelector(selectBooksTotal())
  const ref = useRef(null)
  const {
    pageState: { activeWidgetId },
    actions: { activateWidget, deactivateWidget, registerWidget, unregisterWidget },
  } = useContext(UrlStoreContext)
  const isActive = activeWidgetId === WIDGET_ID

  useEffect(() => {
    registerWidget(WIDGET_ID)

    return () => unregisterWidget(WIDGET_ID)
  }, [])

  useEffect(() => {
    const handleOutsideInteraction = event => {
      if (!ref.current?.contains(event.target))
        deactivateWidget(WIDGET_ID)
    }

    document.addEventListener('focusin', handleOutsideInteraction)
    document.addEventListener('click', handleOutsideInteraction)
    return () => {
      document.removeEventListener('focusin', handleOutsideInteraction)
      document.removeEventListener('click', handleOutsideInteraction)
    }
  }, [])

  const handleClick = useCallback(event => {
    activateWidget(WIDGET_ID)

    const clickedInteractiveControl = event.target.closest(
      'button, a, input, select, textarea, [role="menuitem"]'
    )
    if (!clickedInteractiveControl) ref.current?.focus()
  }, [activateWidget])

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
      className={`sidebar-books-list-linear-controls-widget sidebar-card-widget ${
        isActive ? 'active' : ''
      }`}
      id={WIDGET_ID}
      onClick={handleClick}
      onKeyDown={handleKeyDown}
      ref={ref}
      tabIndex={0}
    >
      <Card.Header className='widget-title books-spine-widget-header'>
        <span className='books-spine-widget-title'>
          { 'All Works' }
        </span>

        { totalCount > 0 ? (
          <span className='books-spine-count-badge'>
            { totalCount }
          </span>
        ) : null }

        <SortingDropdown />
      </Card.Header>

      <Card.Body className='books-spine-widget-body'>
        <BooksSpineStack isActive={isActive} />
      </Card.Body>
    </Card>
  )
}

export default BooksListControls
