import React from 'react'

const LogoutForm = () => {
  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

  return (
    <form
      action='/logout'
      data-turbo='false'
      method='post'
    >
      <input
        name='_method'
        type='hidden'
        value='delete'
      />

      <input
        name='authenticity_token'
        type='hidden'
        value={token || ''}
      />

      <button
        className='dropdown-item'
        type='submit'
      >
        { 'Log out' }
      </button>
    </form>
  )
}

export default LogoutForm
