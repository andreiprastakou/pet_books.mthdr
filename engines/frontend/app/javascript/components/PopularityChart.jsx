import React from 'react'
import PropTypes from 'prop-types'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js'
import { Line } from 'react-chartjs-2'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

const PopularityChart = props => {
  const { points, width } = props
  const options = {
    responsive: false,
    plugins: {
      legend: { display: false },
      title: { display: false },
    },
    scales: {
      x: { display: false, type: 'linear', min: 0, max: width },
      y: { display: false, min: 0 },
    },
    layout: {
      padding: 0,
      autoPadding: false,
    },
    animation: {
      duration: 2000,
    },
  }

  const data = {
    type: 'line',
    datasets: [
      {
        data: points,
        borderColor: 'rgb(255, 99, 132)',
        backgroundColor: 'rgba(255, 99, 132, 0.5)',
        tension: 0.3,
      }
    ],
  }

  return (
    <div className='popularities-chart'>
      <Line
        data={data}
        height='188'
        options={options}
        width={width}
      />
    </div>
  )
}

PopularityChart.propTypes = {
  points: PropTypes.array.isRequired,
  width: PropTypes.number.isRequired,
}

export default PopularityChart
