import { Chart, registerables } from 'chart.js'
import { formatPeriodLabel } from 'stats/date_utils'

Chart.register(...registerables)

const CHART_DATASETS = [
  {
    type: 'bar',
    label: 'Demandes soumises',
    backgroundColor: 'rgba(0, 0, 145, 0.2)',
    borderWidth: 0,
    order: 2,
    dataKey: (item) => item.new_requests + item.reopenings
  },
  {
    type: 'bar',
    label: 'Demandes validées ou refusées',
    backgroundColor: 'rgba(24, 117, 60, 0.2)',
    borderWidth: 0,
    order: 2,
    dataKey: (item) => item.validations + item.refusals
  },
  {
    type: 'line',
    label: 'Demandes en attente de réponse',
    borderColor: '#e1000f',
    backgroundColor: '#e1000f',
    borderWidth: 4,
    pointRadius: 5,
    pointHoverRadius: 7,
    tension: 0.1,
    order: 1,
    dataKey: (item) => item.backlog
  }
]

const CHART_OPTIONS = {
  responsive: true,
  maintainAspectRatio: true,
  aspectRatio: 2.5,
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
      stacked: false
    },
    y: {
      beginAtZero: true,
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

export function renderTimeSeriesChart (canvasElement, timeSeries, existingChartInstance) {
  if (!canvasElement || !timeSeries) return null

  if (existingChartInstance) {
    existingChartInstance.destroy()
  }

  const labels = timeSeries.data.map(item => formatPeriodLabel(item.period, timeSeries.unit))

  const datasets = CHART_DATASETS.map(({ dataKey, ...config }) => ({
    ...config,
    data: timeSeries.data.map(dataKey)
  }))

  const ctx = canvasElement.getContext('2d')
  return new Chart(ctx, {
    type: 'bar',
    data: { labels, datasets },
    options: CHART_OPTIONS
  })
}
