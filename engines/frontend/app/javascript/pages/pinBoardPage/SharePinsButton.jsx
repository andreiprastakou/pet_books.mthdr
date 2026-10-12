import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import { useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import { faLinkSlash } from '@fortawesome/free-solid-svg-icons/faLinkSlash'

import { addErrorMessage, addSuccessMessage } from 'store/notifications/actions'
import apiClient from 'store/userPinsSharings/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const SharePinsButton = () => {
  const dispatch = useDispatch()
  const { routes: { userPinsPagePath }, routesReady } = useContext(UrlStoreContext)
  const [shared, setShared] = useState(false)
  const pending = useRef(false)
  const generation = useRef(0)

  useEffect(() => {
    if (!routesReady) return

    const requestId = generation.current
    apiClient.current()
      .then(() => {
        if (generation.current === requestId) setShared(true)
      })
      .catch(error => {
        if (generation.current !== requestId || error?.status === 404) return
        dispatch(addErrorMessage('Could not check whether your pin board is shared.'))
      })
  }, [dispatch, routesReady])

  const run = useCallback(action => {
    if (pending.current) return null

    pending.current = true
    generation.current += 1
    return action().finally(() => {
      pending.current = false
    })
  }, [])

  const handleShareClick = useCallback(() => run(() => apiClient.create()
    .then(({ code }) => {
      setShared(true)
      const { origin } = window.location
      const { href } = new URL(userPinsPagePath(code), origin)
      return navigator.clipboard.writeText(href)
    })
    .then(() => {
      dispatch(addSuccessMessage('Link copied to clipboard!'))
    })
    .catch(() => {
      dispatch(addErrorMessage('Could not copy the shared pin board link. Please try again.'))
    })), [dispatch, run, userPinsPagePath])

  const handleUnshareClick = useCallback(() => run(() => apiClient.destroy()
    .then(() => {
      setShared(false)
      dispatch(addSuccessMessage('Your pin board is no longer shared.'))
    })
    .catch(() => {
      dispatch(addErrorMessage('Could not unshare your pin board. Please try again.'))
    })), [dispatch, run])

  if (!routesReady) return null

  return (
    <ButtonGroup className='share-pins-buttons'>
      <Button
        aria-label='Copy shared pin board link'
        onClick={handleShareClick}
        title='Copy shared pin board link'
        type='button'
        variant='outline-primary'
      >
        <FontAwesomeIcon icon={faLink} />
      </Button>

      { shared ? (
        <Button
          aria-label='Unshare'
          onClick={handleUnshareClick}
          title='Unshare'
          type='button'
          variant='outline-warning'
        >
          <FontAwesomeIcon icon={faLinkSlash} />
        </Button>
      ) : null }
    </ButtonGroup>
  )
}

export default SharePinsButton
