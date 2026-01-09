import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { setPageIsLoading } from 'store/metadata/actions'
import { selectPage, selectPerPage, selectSortBy } from 'pages/authorsPage/selectors'
import { fetchAuthorsIndex } from 'pages/authorsPage/actions'
import { prepareNavRefs } from 'widgets/navbar/actions'

const Configurer = () => {
  const dispatch = useDispatch()
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const sortBy = useSelector(selectSortBy())

  useEffect(() => {
    dispatch(setPageIsLoading(true))
  }, [])

  useEffect(() => {
    Promise.all([
      dispatch(fetchAuthorsIndex()),
      dispatch(prepareNavRefs()),
    ]).then(() => {
      dispatch(setPageIsLoading(false))
    })
  }, [page, perPage, sortBy])

  return null
}

export default Configurer
