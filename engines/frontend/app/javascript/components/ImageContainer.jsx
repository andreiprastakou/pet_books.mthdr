import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

const ImageContainer = ({ children = null, classes = '', url, onClick = null }) => {
  const styles = {
    backgroundImage: `url(${url})`,
    backgroundSize: 'contain',
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'center',
  }
  return (
    <div
      className={classNames('image-container', classes)}
      onClick={onClick}
      style={styles}
    >
      { children }
    </div>
  )
}

ImageContainer.propTypes = {
  children: PropTypes.node,
  classes: PropTypes.string,
  onClick: PropTypes.func,
  url: PropTypes.string.isRequired,
}

export default ImageContainer
