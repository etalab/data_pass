import { formatDuration } from 'stats/date_utils'
import { renderTimeSeriesChart } from 'stats/chart_manager'

export async function fetchFilterOptions () {
  const response = await fetch('/stats/filters')
  if (!response.ok) throw new Error(`HTTP ${response.status}`)
  return response.json()
}

export async function fetchStatsData (startDate, endDate, providers, types, forms, signal) {
  const params = new URLSearchParams({ start_date: startDate, end_date: endDate })

  providers.forEach(p => params.append('providers[]', p))
  types.forEach(t => params.append('authorization_types[]', t))
  forms.forEach(f => params.append('forms[]', f))

  const response = await fetch(`/stats/data?${params}`, { signal })
  if (!response.ok) throw new Error(`HTTP ${response.status}`)
  return response.json()
}

export function updateSummaryCards (targets, volume) {
  targets.totalRequestsCount.textContent = volume.total_requests_submitted || 0
  targets.reopeningsCount.textContent = volume.reopenings_submitted || 0
  targets.validationsCount.textContent = volume.validations || 0
  targets.refusalsCount.textContent = volume.refusals || 0
}

export function updateTimeSeriesChart (canvasElement, timeSeries, existingChartInstance) {
  return renderTimeSeriesChart(canvasElement, timeSeries, existingChartInstance)
}

export function updateDurationCards (targets, durations) {
  updateSingleDurationCard(
    targets.percentile50TimeToSubmit,
    targets.percentile80TimeToSubmit,
    durations?.time_to_submit
  )
  updateSingleDurationCard(
    targets.percentile50TimeToFirstInstruction,
    targets.percentile80TimeToFirstInstruction,
    durations?.time_to_first_instruction
  )
  updateSingleDurationCard(
    targets.percentile50TimeToFinalInstruction,
    targets.percentile80TimeToFinalInstruction,
    durations?.time_to_final_instruction
  )
}

function updateSingleDurationCard (percentile50Target, percentile80Target, data) {
  const p50Seconds = data?.percentile_50_seconds
  const p80Seconds = data?.percentile_80_seconds

  percentile50Target.textContent = formatDuration(p50Seconds)
  percentile80Target.textContent = formatDuration(p80Seconds)

  const p50Label = percentile50Target.closest('p')?.previousElementSibling
  if (p50Label) p50Label.style.visibility = p50Seconds ? 'visible' : 'hidden'

  const p80Paragraph = percentile80Target.closest('p')
  if (p80Paragraph) p80Paragraph.style.visibility = p80Seconds ? 'visible' : 'hidden'
}
