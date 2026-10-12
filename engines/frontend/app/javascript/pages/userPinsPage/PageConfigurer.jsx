import { useEffect, useRef } from 'react'
import { useDispatch } from 'react-redux'
import PropTypes from 'prop-types'

import { addErrorMessage } from 'store/notifications/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import { fetchPinBoard } from 'store/pinBoard/actions'
import apiClient from 'store/userPinsSharings/apiClient'

const Configurer = ({ code, onStatus }) => {
  const dispatch = useDispatch()
  const loadedCode = useRef(null)
  const activeCode = useRef(code)
  activeCode.current = code

  useEffect(() => {
    if (!code || loadedCode.current === code) return

    loadedCode.current = code
    onStatus('loading')
    dispatch(setPageIsLoading(true))

    apiClient.get(code).then(() => {
      if (activeCode.current !== code) return 'stale'
      onStatus('ready')
      return dispatch(fetchPinBoard(code))
    }).catch(error => {
      if (activeCode.current !== code) return 'stale'
      if (error?.status === 404) {
        onStatus('missing')
        return 'missing'
      }
      throw error
    }).catch(() => {
      if (activeCode.current === code)
        dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      if (activeCode.current === code) dispatch(setPageIsLoading(false))
    })
  }, [code, onStatus])

  return null
}

Configurer.propTypes = {
  code: PropTypes.string,
  onStatus: PropTypes.func.isRequired,
}

export default Configurer
