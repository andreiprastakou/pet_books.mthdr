import React, { useCallback, useContext, useEffect, useRef, useState } from 'react'
import { useDispatch } from 'react-redux'
import { Button, ButtonGroup } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faLink } from '@fortawesome/free-solid-svg-icons/faLink'
import { faLinkSlash } from '@fortawesome/free-solid-svg-icons/faLinkSlash'

import { addErrorMessage, addSuccessMessage } from 'store/notifications/actions'
import apiClient from 'store/userReadsSharings/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const ShareReadsButton = () => {
  const dispatch = useDispatch()
  const { routes: { userReadsPagePath }, routesReady } = useContext(UrlStoreContext)
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
        dispatch(addErrorMessage('Could not check whether your reads are shared.'))
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
      const { href } = new URL(userReadsPagePath(code), window.location.origin)
      return navigator.clipboard.writeText(href)
    })
    .then(() => {
      dispatch(addSuccessMessage('Link copied to clipboard!'))
    })
    .catch(() => {
      dispatch(addErrorMessage('Could not copy the shared reads link. Please try again.'))
    })), [dispatch, run, userReadsPagePath])

  const handleUnshareClick = useCallback(() => run(() => apiClient.destroy()
    .then(() => {
      setShared(false)
      dispatch(addSuccessMessage('Your reads are no longer shared.'))
    })
    .catch(() => {
      dispatch(addErrorMessage('Could not unshare your reads. Please try again.'))
    })), [dispatch, run])

  if (!routesReady) return null

  return (
    <ButtonGroup className='share-reads-buttons'>
      <Button
        aria-label='Copy shared reads link'
        onClick={handleShareClick}
        title='Copy shared reads link'
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

export default ShareReadsButton
