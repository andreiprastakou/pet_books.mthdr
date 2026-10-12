import React from 'react'
import { Spinner } from 'react-bootstrap'

const PageLoading = () => (
  <div className='page-loading'>
    <Spinner
      animation='border'
      className='page-loading-spinner'
      role='status'
    >
      <span className='visually-hidden'>
        { 'Loading' }
      </span>
    </Spinner>
  </div>
)

export default PageLoading
