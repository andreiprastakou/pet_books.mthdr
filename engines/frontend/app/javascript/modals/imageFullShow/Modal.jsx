import React, { useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import ImageViewer from 'react-simple-image-viewer'

import { setImageSrc } from 'modals/imageFullShow/actions'
import { selectImageSrc } from 'modals/imageFullShow/selectors'

const ImageModal = () => {
  const src = useSelector(selectImageSrc())
  const dispatch = useDispatch()
  const handleClose = useCallback(() => dispatch(setImageSrc(null)), [])

  if (!src)  return null

  return (
    <ImageViewer
      closeOnClickOutside
      onClose={handleClose}
      src={[src]}
    />
  )
}

export default ImageModal
