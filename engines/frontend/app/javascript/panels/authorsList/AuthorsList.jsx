import React, { useCallback, useContext, useEffect, useRef } from 'react'
import { useSelector } from 'react-redux'
import { Card, Row } from 'react-bootstrap'

import {
  selectAuthorsTotal,
  selectPage,
  selectPerPage,
  selectSortedAuthors,
} from 'pages/authorsPage/selectors'
import AuthorsListItem from 'panels/authorsList/AuthorsListItem'
import Pagination from 'panels/authorsList/Pagination'
import SortingDropdown from 'panels/authorsList/SortingDropdown'
import { selectCurrentAuthorId } from 'store/axis/selectors'
import UrlStoreContext from 'store/urlStore/Context'
import {
  isBlocked,
  keyType,
  pageSelection,
  targetSelection,
} from 'utils/paginatedGridNavigation'

export const WIDGET_ID = 'authors-list'

const usePageSelection = ({ authors, authorsKey, page, pendingPageSelection, showAuthor }) => {
  const previousAuthorsKey = useRef(authorsKey)

  useEffect(() => {
    const pending = pendingPageSelection.current
    const authorsChanged = previousAuthorsKey.current !== authorsKey
    if (!authorsChanged || authors.length === 0) return

    if (pending?.page === page && pending.authorsKey !== authorsKey) {
      pendingPageSelection.current = null
      showAuthor(authors[Math.min(pending.index, authors.length - 1)].id)
    } else
      showAuthor(authors[0].id)
    previousAuthorsKey.current = authorsKey
  }, [authors, authorsKey, page, pendingPageSelection, showAuthor])
}

const useInitialSelection = ({ authors, selectedAuthorId, showAuthor }) => {
  useEffect(() => {
    if (selectedAuthorId || authors.length === 0) return

    showAuthor(authors[0].id)
  }, [authors, selectedAuthorId, showAuthor])
}

const handleAuthorsKeyDown = (event, {
  authors, authorPagePath, page, perPage, selectedAuthorId, showAuthor,
  switchToIndexPage, totalCount,
}) => {
  const type = keyType(event.key)
  const index = authors.findIndex(author => author.id === selectedAuthorId)
  const lastIndex = authors.length - 1
  const lastPage = Math.ceil(totalCount / perPage)

  if (index < 0 || !type ||
      (type !== 'enter' && isBlocked({ type, index, lastIndex, page, lastPage }))) return null

  event.preventDefault()
  event.stopPropagation()

  if (type === 'enter') {
    window.location.assign(authorPagePath(authors[index].id))
    return null
  }

  if (type === 'pageUp' || type === 'pageDown') {
    const target = pageSelection({ type, index, page, perPage, totalCount })
    switchToIndexPage(target.page, perPage)
    return target
  }

  const target = targetSelection({
    type, index, lastIndex, page, perPage, totalCount,
  })
  if (target.page !== page) {
    switchToIndexPage(target.page, perPage)
    return target
  }

  showAuthor(authors[target.index].id)
  return null
}

// eslint-disable-next-line max-lines-per-function
const AuthorsList = () => {
  const {
    pageState: { activeWidgetId, registeredWidgetIds, sortOrder },
    routes: { authorPagePath },
    routesReady,
    actions: {
      activateWidget,
      deactivateWidget,
      registerWidget,
      showAuthor,
      switchToIndexPage,
      unregisterWidget,
    },
  } = useContext(UrlStoreContext)
  const authors = useSelector(selectSortedAuthors(sortOrder))
  const authorsKey = authors.map(author => author.id).join(',')
  const totalCount = useSelector(selectAuthorsTotal())
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const selectedAuthorId = useSelector(selectCurrentAuthorId())
  const ref = useRef(null)
  const pendingPageSelection = useRef(null)
  const hasActivated = useRef(false)
  const isActive = activeWidgetId === WIDGET_ID
  useEffect(() => {
    registerWidget(WIDGET_ID)

    return () => unregisterWidget(WIDGET_ID)
  }, [])

  useEffect(() => {
    if (hasActivated.current || !registeredWidgetIds.includes(WIDGET_ID)) return

    hasActivated.current = true
    activateWidget(WIDGET_ID)
    ref.current?.focus()
  }, [activateWidget, registeredWidgetIds])

  usePageSelection({ authors, authorsKey, page, pendingPageSelection, showAuthor })
  useInitialSelection({ authors, selectedAuthorId, showAuthor })
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
    if (!isActive || !routesReady || authors.length === 0) return null
    const pending = handleAuthorsKeyDown(event, {
      authors, authorPagePath, page, perPage, selectedAuthorId, showAuthor,
      switchToIndexPage, totalCount,
    })
    if (pending) pendingPageSelection.current = { ...pending, authorsKey }
    return null
  }, [
    authorPagePath, authors, isActive, page, perPage, selectedAuthorId, showAuthor,
    routesReady, switchToIndexPage, totalCount,
  ])
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
