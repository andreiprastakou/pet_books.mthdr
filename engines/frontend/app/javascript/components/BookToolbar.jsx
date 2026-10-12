import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import { useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import PropTypes from 'prop-types'
import { faBook } from '@fortawesome/free-solid-svg-icons/faBook'
import { faBookOpenReader } from '@fortawesome/free-solid-svg-icons/faBookOpenReader'

import PinButton from 'components/PinButton'
import { saveBookPin, saveBookRead } from 'store/books/actions'
import { addErrorMessage, addSuccessMessage } from 'store/notifications/actions'
import UrlStoreContext from 'store/urlStore/Context'

const ReadButton = ({ bookId, read: savedRead }) => {
  const dispatch = useDispatch()
  const [read, setRead] = useState(savedRead)
  const [hovered, setHovered] = useState(false)
  const pending = useRef(false)
  const title = read ? 'Mark as not read' : 'Mark as read'
  const showReadIcon = read !== hovered

  useEffect(() => {
    setRead(savedRead)
  }, [savedRead])

  const handleMouseEnter = useCallback(() => setHovered(true), [])
  const handleMouseLeave = useCallback(() => setHovered(false), [])
  const handleClick = useCallback(() => {
    if (pending.current) return

    const nextRead = !read
    pending.current = true
    setRead(nextRead)
    dispatch(saveBookRead(bookId, nextRead))
      .catch(() => {
        setRead(savedRead)
        dispatch(addErrorMessage('Could not update read status. Please try again.'))
      })
      .finally(() => {
        pending.current = false
      })
  }, [bookId, dispatch, read, savedRead])

  return (
    <Button
      aria-label={title}
      aria-pressed={read}
      onClick={handleClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      title={title}
      type='button'
      variant='outline-warning'
    >
      <FontAwesomeIcon
        icon={showReadIcon ? faBookOpenReader : faBook}
        transform='shrink-2'
      />
    </Button>
  )
}

ReadButton.propTypes = {
  bookId: PropTypes.number.isRequired,
  read: PropTypes.bool.isRequired,
}

const BookToolbar = ({ bookId, bookPageHref, pinned, read }) => {
  const dispatch = useDispatch()
  const { routesReady } = useContext(UrlStoreContext)
  const savePin = useCallback(
    nextPinned => dispatch(saveBookPin(bookId, nextPinned)),
    [bookId, dispatch]
  )

  const copyBookPageLink = useCallback(event => {
    event.preventDefault()
    const absoluteBookPageHref = new URL(bookPageHref, window.location.origin).href
    navigator.clipboard.writeText(absoluteBookPageHref)
    dispatch(addSuccessMessage('Link copied to clipboard!'))
  }, [bookPageHref, dispatch])

  if (!routesReady) return null

  return (
    <div>
      <ButtonGroup className='book-toolbar'>
        <PinButton
          onChange={savePin}
          pinned={pinned}
        />

        <ReadButton
          bookId={bookId}
          read={read}
        />

        <Button
          as='a'
          className='internal-link'
          href={bookPageHref}
          onClick={copyBookPageLink}
          title='Copy book page link'
          variant='outline-primary'
        >
          <FontAwesomeIcon icon={faLink} />
        </Button>

      </ButtonGroup>
    </div>
  )
}

BookToolbar.propTypes = {
  bookId: PropTypes.number.isRequired,
  bookPageHref: PropTypes.string.isRequired,
  pinned: PropTypes.bool.isRequired,
  read: PropTypes.bool.isRequired,
}

export default BookToolbar
