import { useEffect } from 'react'
import { useDispatch } from 'react-redux'

import { setPageIsLoading } from 'store/metadata/actions'
import { fetchTagsIndex } from 'store/tags/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'

const Configurer = () => {
  const dispatch = useDispatch()

  useEffect(() => {
    dispatch(setPageIsLoading(true))
    Promise.all([
      dispatch(fetchTagsIndex()),
      dispatch(prepareNavRefs()),
    ]).then(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [])

  return null
}

export default Configurer
