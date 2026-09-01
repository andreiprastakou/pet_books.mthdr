import React, { useContext, useEffect, useState } from 'react'
import { NavDropdown } from 'react-bootstrap'

import apiClient from 'store/publicLists/apiClient'
import UrlStoreContext from 'store/urlStore/Context'

const PublicListsNavList = () => {
  const [listTypes, setListTypes] = useState([])
  const { routes: { listPagePath } } = useContext(UrlStoreContext)

  useEffect(() => {
    apiClient.getTypes().then(setListTypes)
  }, [])

  return (
    <>
      { listTypes.map(listType => (
        <NavDropdown.Item
          href={listPagePath(listType.id)}
          key={listType.id}
        >
          { listType.name }
        </NavDropdown.Item>
      )) }
    </>
  )
}

export default PublicListsNavList
