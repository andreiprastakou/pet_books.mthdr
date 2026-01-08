import { useContext, useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { selectPage, selectPerPage, selectSortBy } from 'widgets/booksListLinear/selectors'
import { fetchBooks, switchToFirstBook } from 'widgets/booksListLinear/actions'
import UrlStoreContext from 'store/urlStore/Context'

const WidgetConfigurer = () => {
  const dispatch = useDispatch()
  const page = useSelector(selectPage())
  const perPage = useSelector(selectPerPage())
  const sortBy = useSelector(selectSortBy())
  const { routesReady } = useContext(UrlStoreContext)

  if (!routesReady) return null

  useEffect(() => {
    dispatch(fetchBooks()).then(() =>
      dispatch(switchToFirstBook())
    )
  }, [page, perPage, sortBy])
  return null
}

export default WidgetConfigurer
