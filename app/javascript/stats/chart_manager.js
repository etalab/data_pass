import { Chart, registerables } from 'chart.js'
import { formatPeriodLabel } from 'stats/date_utils'

Chart.register(...registerables)

const STACK_REQUESTS = 'requests'
const STACK_INSTRUCTIONS = 'instructions'

function buildChartDatasets (labels) {
  if (!labels || labels.length !== 4) {
    throw new Error('Chart labels are required (expected 4 labels: submitted, validated, refused, pending).')
  }
  const [submitted, validated, refused, pending] = labels
  return [
    {
      type: 'bar',
      label: submitted,
      backgroundColor: 'rgba(0, 0, 145, 0.2)',
      borderWidth: 0,
      order: 2,
      stack: STACK_REQUESTS,
      dataKey: (item) => item.new_requests + item.reopenings
    },
    {
      type: 'bar',
      label: validated,
      backgroundColor: 'rgba(24, 117, 60, 0.2)',
      borderWidth: 0,
      order: 3,
      stack: STACK_INSTRUCTIONS,
      dataKey: (item) => item.validations
    },
    {
      type: 'bar',
      label: refused,
      backgroundColor: 'rgba(225, 0, 15, 0.2)',
      borderWidth: 0,
      order: 3,
      stack: STACK_INSTRUCTIONS,
      dataKey: (item) => item.refusals
    },
    {
      type: 'line',
      label: pending,
      borderColor: '#3d3d3d',
      backgroundColor: '#3d3d3d',
      borderWidth: 4,
      pointRadius: 5,
      pointHoverRadius: 7,
      tension: 0.1,
      order: 1,
      dataKey: (item) => item.backlog
    }
  ]
}

const MOBILE_BREAKPOINT = 768
const ASPECT_RATIO_DESKTOP = 2.5
const ASPECT_RATIO_MOBILE = 1.2

function getChartOptions () {
  const isMobile = typeof window !== 'undefined' && window.innerWidth < MOBILE_BREAKPOINT
  const aspectRatio = isMobile ? ASPECT_RATIO_MOBILE : ASPECT_RATIO_DESKTOP
  return {
    responsive: true,
    maintainAspectRatio: true,
    aspectRatio,
    interaction: {
      mode: 'index',
      intersect: false
    },
    plugins: {
      legend: {
        display: true,
        position: 'bottom'
      },
      tooltip: {
        mode: 'index',
        intersect: false
      }
    },
    scales: {
      x: {
        grid: { display: false },
        stacked: true,
        ticks: {
          maxTicksLimit: 12,
          maxRotation: 45,
          minRotation: 45
        }
      },
      y: {
        beginAtZero: true,
        stacked: true,
        ticks: { precision: 0 }
      }
    },
    datasets: {
      bar: {
        barPercentage: 1.0,
        categoryPercentage: 0.8
      }
    }
  }
}

export function renderTimeSeriesChart (canvasElement, timeSeries, existingChartInstance, chartLabels) {
  if (!canvasElement || !timeSeries) return null

  if (existingChartInstance) {
    existingChartInstance.destroy()
  }

  const periodLabels = timeSeries.data.map(item => formatPeriodLabel(item.period, timeSeries.unit))
  const chartDatasets = buildChartDatasets(chartLabels)

  const datasets = chartDatasets.map(({ dataKey, ...config }) => ({
    ...config,
    data: timeSeries.data.map(dataKey)
  }))

  const ctx = canvasElement.getContext('2d')
  return new Chart(ctx, {
    type: 'bar',
    data: { labels: periodLabels, datasets },
    options: getChartOptions()
  })
}
