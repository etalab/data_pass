export function formatDate (date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

export function calculateRangeDates (range) {
  const today = new Date()
  let startDate, endDate

  if (range.startsWith('year-')) {
    const year = parseInt(range.replace('year-', ''))
    const currentYear = today.getFullYear()

    startDate = new Date(year, 0, 1)

    if (year === currentYear) {
      endDate = new Date(today)
    } else {
      endDate = new Date(year, 11, 31)
    }
  } else {
    endDate = new Date(today)
    switch (range) {
      case 'last-30-days':
        startDate = new Date(today)
        startDate.setDate(startDate.getDate() - 30)
        break
      case 'last-3-months':
        startDate = new Date(today)
        startDate.setMonth(startDate.getMonth() - 3)
        break
      case 'last-year':
        startDate = new Date(today)
        startDate.setFullYear(startDate.getFullYear() - 1)
        break
      default:
        return {}
    }
  }

  return { startDate, endDate }
}

export function formatPeriodLabel (period, unit) {
  const date = new Date(period + 'T00:00:00')

  switch (unit) {
    case 'day':
      return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' })
    case 'week':
      return `Sem. ${getWeekNumber(date)} ${date.getFullYear()}`
    case 'month':
      return date.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
    case 'year':
      return date.getFullYear().toString()
    default:
      return period
  }
}

export function formatDuration (seconds) {
  if (!seconds || isNaN(seconds)) return 'N/A'

  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (days > 0) {
    return `${days} jour${days > 1 ? 's' : ''}`
  } else if (hours > 0) {
    return `${hours} heure${hours > 1 ? 's' : ''}`
  } else if (minutes > 0) {
    return `${minutes} minute${minutes > 1 ? 's' : ''}`
  } else {
    const flooredSeconds = Math.floor(seconds)
    return `${flooredSeconds} seconde${flooredSeconds > 1 ? 's' : ''}`
  }
}

function getWeekNumber (date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
  const dayNum = d.getUTCDay() || 7
  d.setUTCDate(d.getUTCDate() + 4 - dayNum)
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
  return Math.ceil((((d - yearStart) / 86400000) + 1) / 7)
}
