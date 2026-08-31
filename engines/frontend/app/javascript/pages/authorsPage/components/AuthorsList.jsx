import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { useSelector } from 'react-redux'
import { Card, Row } from 'react-bootstrap'

import { selectAuthorsTotal, selectSortedAuthors } from 'pages/authorsPage/selectors'
import AuthorsListItem from 'pages/authorsPage/components/AuthorsListItem'
import Pagination from 'sidebar/authorsIndexControls/Pagination'
import SortingDropdown from 'sidebar/authorsIndexControls/SortingDropdown'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import UrlStoreContext from 'store/urlStore/Context'

export const WIDGET_ID = 'authors-list'

const AuthorsList = () => {
  const {
    pageState: { activeWidgetId, sortOrder },
    actions: { activateWidget, deactivateWidget, registerWidget, showAuthor, unregisterWidget },
  } = useContext(UrlStoreContext)
  const authors = useSelector(selectSortedAuthors(sortOrder))
  const totalCount = useSelector(selectAuthorsTotal())
  const selectedAuthorId = useSelector(selectCurrentAuthorId())
  const ref = useRef(null)
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

  const handleFocus = useCallback(() => activateWidget(WIDGET_ID), [activateWidget])
  const handleKeyDown = useCallback(event => {
    if (!isActive || authors.length === 0) return

    if (event.key !== 'ArrowLeft' && event.key !== 'Left' &&
        event.key !== 'ArrowRight' && event.key !== 'Right') return

    event.preventDefault()
    event.stopPropagation()

    const currentIndex = authors.findIndex(author => author.id === selectedAuthorId)
    const direction = event.key === 'ArrowLeft' || event.key === 'Left' ? -1 : 1
    const targetIndex = currentIndex < 0
      ? 0
      : (currentIndex + direction + authors.length) % authors.length
    showAuthor(authors[targetIndex].id)
  }, [authors, isActive, selectedAuthorId, showAuthor])

  return (
    <Card
      aria-label='Authors'
      className={`authors-list-widget sidebar-card-widget ${isActive ? 'active' : ''}`}
      id={WIDGET_ID}
      onClick={handleClick}
      onFocusCapture={handleFocus}
      onKeyDown={handleKeyDown}
      ref={ref}
      tabIndex={0}
    >
      <Card.Header className='widget-title authors-list-widget-header'>
        <span className='authors-list-widget-title'>
          { 'All Authors' }
        </span>

        { totalCount > 0 ? (
          <span className='authors-list-count-badge'>
            { totalCount }
          </span>
        ) : null }

        <SortingDropdown />

        <Pagination />
      </Card.Header>

      <Card.Body className='authors-list-widget-body'>
        <div className='authors-list'>
          <Row>
            { authors.map(author => (
              <AuthorsListItem
                author={author}
                key={author.id}
              />
            )) }
          </Row>
        </div>
      </Card.Body>
    </Card>
  )
}

export default AuthorsList
