import React from 'react'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'
import { Row } from 'react-bootstrap'

import { selectPageIsLoading } from 'store/metadata/selectors'

const Layout = ({ children, classes }) => {
  const pageIsLoading = useSelector(selectPageIsLoading())
  if (pageIsLoading)
    return 'Wait...'

  return (
    <Row className={classes}>
      { children }
    </Row>
  )
}

Layout.propTypes = {
  children: PropTypes.node.isRequired,
  classes: PropTypes.string,
}

Layout.defaultProps = {
  classes: '',
}

export default Layout
