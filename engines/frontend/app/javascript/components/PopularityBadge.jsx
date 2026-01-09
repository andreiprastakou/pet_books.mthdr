import React from 'react'
import PropTypes from 'prop-types'

const PopularityBadge = props => {
  const { rank, points } = props
  if (points === 0)  return null

  return (
    <span className='ratings-info'>
      <span className='popularity-points'>
        { `${points.toLocaleString()} pts` }
      </span>

      { rank <= 100 &&
        <span className='rank'>
          { ` (#${rank})` }
        </span>}
    </span>
  )
}

PopularityBadge.propTypes = {
  points: PropTypes.number.isRequired,
  rank: PropTypes.number.isRequired
}

export default PopularityBadge
