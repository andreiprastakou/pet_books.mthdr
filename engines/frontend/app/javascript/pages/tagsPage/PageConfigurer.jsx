import { useEffect } from 'react'
import { useDispatch } from 'react-redux'

import { addErrorMessage } from 'store/notifications/actions'
import { setPageIsLoading } from 'store/metadata/actions'
import { fetchTagsIndex } from 'store/tags/actions'
import { prepareNavRefs } from 'store/navbar/actions'

const Configurer = () => {
  const dispatch = useDispatch()

  useEffect(() => {
    dispatch(setPageIsLoading(true))
    Promise.all([
      dispatch(fetchTagsIndex()),
      dispatch(prepareNavRefs()),
    ]).catch(() => {
      dispatch(addErrorMessage('Unable to load this page. Please try again.'))
    }).finally(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [])

  return null
}

export default Configurer
