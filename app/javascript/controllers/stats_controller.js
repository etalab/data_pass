import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static DEBOUNCE_DELAY_MS = 1000

  static targets = [
    'startDate',
    'endDate',
    'providerSelect',
    'typeSelect',
    'formSelect',
    'newRequestsCount',
    'reopeningsCount',
    'validationsCount',
    'refusalsCount',
    'percentile50TimeToSubmit',
    'percentile90TimeToSubmit',
    'percentile50TimeToFirstInstruction',
    'percentile90TimeToFirstInstruction',
    'percentile50TimeToFinalInstruction',
    'percentile90TimeToFinalInstruction',
    'loadingIndicator',
    'quickRanges',
    'timeSeriesChart',
    'migrationWarning'
  ]

  connect () {
    this.allProviders = []
    this.allTypes = []
    this.allForms = []
    this.timeSeriesChartInstance = null
    this.isInitializing = true
    this.debounceTimeout = null
    this.addDynamicYearButtons()
    this.loadFiltersFromURL()
    this.highlightActiveQuickRange()
    this.loadFilterOptions()
  }

  addDynamicYearButtons () {
    const currentYear = new Date().getFullYear()
    const lastYear = currentYear - 1

    const lastYearBtn = document.createElement('button')
    lastYearBtn.className = 'fr-btn fr-btn--sm fr-btn--tertiary-no-outline'
    lastYearBtn.type = 'button'
    lastYearBtn.dataset.action = 'click->stats#setDateRange'
    lastYearBtn.dataset.range = `year-${lastYear}`
    lastYearBtn.textContent = `Année ${lastYear}`

    const currentYearBtn = document.createElement('button')
    currentYearBtn.className = 'fr-btn fr-btn--sm fr-btn--tertiary-no-outline'
    currentYearBtn.type = 'button'
    currentYearBtn.dataset.action = 'click->stats#setDateRange'
    currentYearBtn.dataset.range = `year-${currentYear}`
    currentYearBtn.textContent = `Année ${currentYear}`

    this.quickRangesTarget.appendChild(lastYearBtn)
    this.quickRangesTarget.appendChild(currentYearBtn)
  }

  disconnect () {
    if (this.timeSeriesChartInstance) {
      this.timeSeriesChartInstance.destroy()
    }
  }

  setDefaultDates () {
    const endDate = new Date()
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 1)

    this.endDateTarget.valueAsDate = endDate
    this.startDateTarget.valueAsDate = startDate
  }

  loadFiltersFromURL () {
    const params = new URLSearchParams(window.location.search)

    if (params.has('start_date')) {
      this.startDateTarget.value = params.get('start_date')
    } else {
      const startDate = new Date()
      startDate.setFullYear(startDate.getFullYear() - 1)
      this.startDateTarget.valueAsDate = startDate
    }

    if (params.has('end_date')) {
      this.endDateTarget.value = params.get('end_date')
    } else {
      this.endDateTarget.valueAsDate = new Date()
    }

    if (params.has('provider')) {
      this.providerSelectTarget.value = params.get('provider')
    }

    if (params.has('type')) {
      this.typeSelectTarget.value = params.get('type')
    }

    if (params.has('form')) {
      this.formSelectTarget.value = params.get('form')
    }
  }

  updateURL () {
    const params = new URLSearchParams()

    params.set('start_date', this.startDateTarget.value)
    params.set('end_date', this.endDateTarget.value)

    if (this.providerSelectTarget.value) {
      params.set('provider', this.providerSelectTarget.value)
    }

    if (this.typeSelectTarget.value) {
      params.set('type', this.typeSelectTarget.value)
    }

    if (this.formSelectTarget.value) {
      params.set('form', this.formSelectTarget.value)
    }

    const newURL = `${window.location.pathname}?${params.toString()}`
    window.history.pushState({}, '', newURL)
  }

  async loadFilterOptions () {
    try {
      const response = await fetch('/stats/filters')
      const filters = await response.json()

      this.allProviders = filters.providers || []
      this.allTypes = filters.types || []
      this.allForms = filters.forms || []

      this.populateProviderSelect()
      this.populateTypeSelect()
      this.populateFormSelect()

      this.restoreFiltersFromURL()

      this.isInitializing = false
      await this.loadData()
    } catch (error) {
      console.error('Error loading filter options:', error)
      this.isInitializing = false
      await this.loadData()
    }
  }

  restoreFiltersFromURL () {
    const params = new URLSearchParams(window.location.search)

    if (params.has('provider')) {
      this.providerSelectTarget.value = params.get('provider')
      this.populateTypeSelect()
    }

    if (params.has('type')) {
      this.typeSelectTarget.value = params.get('type')
      this.populateFormSelect()
    }

    if (params.has('form')) {
      this.formSelectTarget.value = params.get('form')
    }
  }

  populateProviderSelect () {
    this.providerSelectTarget.innerHTML = '<option value="">Tous les fournisseurs</option>'
    this.allProviders.forEach(provider => {
      const option = document.createElement('option')
      option.value = provider.slug
      option.textContent = provider.name
      this.providerSelectTarget.appendChild(option)
    })
  }

  populateTypeSelect () {
    const selectedProviders = this.getSelectedProviders()
    const currentValue = this.typeSelectTarget.value
    this.typeSelectTarget.innerHTML = '<option value="">Tous les types</option>'

    // Disable if no provider selected
    if (selectedProviders.length === 0) {
      this.typeSelectTarget.disabled = true
      return
    }

    this.typeSelectTarget.disabled = false

    const filteredTypes = this.allTypes.filter(type => selectedProviders.includes(type.provider_slug))

    filteredTypes.forEach(type => {
      const option = document.createElement('option')
      option.value = type.class_name
      option.textContent = type.name
      this.typeSelectTarget.appendChild(option)
    })

    // Restore previous selection if still available
    if (currentValue && Array.from(this.typeSelectTarget.options).some(opt => opt.value === currentValue)) {
      this.typeSelectTarget.value = currentValue
    }
  }

  populateFormSelect () {
    const selectedProviders = this.getSelectedProviders()
    const selectedTypes = this.getSelectedTypes()
    const currentValue = this.formSelectTarget.value
    this.formSelectTarget.innerHTML = '<option value="">Tous les formulaires</option>'

    // Disable if no provider or no type selected
    if (selectedProviders.length === 0 || selectedTypes.length === 0) {
      this.formSelectTarget.disabled = true
      return
    }

    this.formSelectTarget.disabled = false

    const filteredForms = this.allForms.filter(form => selectedTypes.includes(form.authorization_type))

    filteredForms.forEach(form => {
      const option = document.createElement('option')
      option.value = form.uid
      option.textContent = form.name
      this.formSelectTarget.appendChild(option)
    })

    // Restore previous selection if still available
    if (currentValue && Array.from(this.formSelectTarget.options).some(opt => opt.value === currentValue)) {
      this.formSelectTarget.value = currentValue
    }
  }

  getSelectedProviders () {
    const value = this.providerSelectTarget.value
    return value ? [value] : []
  }

  getSelectedTypes () {
    const value = this.typeSelectTarget.value
    return value ? [value] : []
  }

  getSelectedForms () {
    const value = this.formSelectTarget.value
    return value ? [value] : []
  }

  clearFilters () {
    // Reset date range to last 12 months
    const endDate = new Date()
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 1)

    this.startDateTarget.valueAsDate = startDate
    this.endDateTarget.valueAsDate = endDate

    // Reset all filter dropdowns
    this.providerSelectTarget.value = ''
    this.typeSelectTarget.value = ''
    this.formSelectTarget.value = ''

    // Update everything
    this.updateFilters()
  }

  setDateRange (event) {
    const range = event.currentTarget.dataset.range
    const { startDate, endDate } = this.calculateRangeDates(range)

    if (!startDate || !endDate) return

    this.startDateTarget.value = this.formatDate(startDate)
    this.endDateTarget.value = this.formatDate(endDate)

    this.updateFilters()
  }

  highlightActiveQuickRange () {
    const buttons = this.quickRangesTarget.querySelectorAll('button')
    const currentStart = this.startDateTarget.value
    const currentEnd = this.endDateTarget.value

    buttons.forEach(button => {
      const range = button.dataset.range
      const { startDate, endDate } = this.calculateRangeDates(range)

      if (!startDate || !endDate) {
        button.classList.remove('fr-btn--secondary')
        button.classList.add('fr-btn--tertiary-no-outline')
        return
      }

      const formattedStart = this.formatDate(startDate)
      const formattedEnd = this.formatDate(endDate)

      const startMatches = formattedStart === currentStart
      const endMatches = formattedEnd === currentEnd

      if (startMatches && endMatches) {
        button.classList.remove('fr-btn--tertiary-no-outline')
        button.classList.add('fr-btn--secondary')
      } else {
        button.classList.remove('fr-btn--secondary')
        button.classList.add('fr-btn--tertiary-no-outline')
      }
    })
  }

  calculateRangeDates (range) {
    const today = new Date()
    let startDate, endDate

    if (range.startsWith('year-')) {
      const year = parseInt(range.replace('year-', ''))
      const currentYear = today.getFullYear()

      startDate = new Date(year, 0, 1)

      // For current year, use today as end date
      // For past years, use Dec 31
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

  formatDate (date) {
    // Handle timezone offset to get local date string
    const offset = date.getTimezoneOffset()
    const localDate = new Date(date.getTime() - (offset * 60 * 1000))
    return localDate.toISOString().split('T')[0]
  }

  updateFiltersDebounced () {
    if (this.isInitializing) {
      return
    }

    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    this.debounceTimeout = setTimeout(() => {
      this.updateFilters()
    }, this.constructor.DEBOUNCE_DELAY_MS)
  }

  async updateFilters () {
    if (this.isInitializing) {
      return
    }

    this.populateTypeSelect()
    this.populateFormSelect()

    this.highlightActiveQuickRange()

    this.updateURL()

    await this.loadData()
  }

  showLoading () {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.style.display = 'block'
    }
  }

  hideLoading () {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.style.display = 'none'
    }
  }

  async loadData () {
    try {
      this.showLoading()
      this.updateMigrationWarning()

      const params = new URLSearchParams({
        start_date: this.startDateTarget.value,
        end_date: this.endDateTarget.value
      })

      const selectedProviders = this.getSelectedProviders()
      const selectedTypes = this.getSelectedTypes()
      const selectedForms = this.getSelectedForms()

      selectedProviders.forEach(p => params.append('providers[]', p))
      selectedTypes.forEach(t => params.append('authorization_types[]', t))
      selectedForms.forEach(f => params.append('forms[]', f))

      const response = await fetch(`/stats/data?${params}`)
      const data = await response.json()

      this.updateSummaryCards(data.volume)
      await this.updateTimeSeriesChart(data.time_series)
      this.updateDurationCards(data.durations)

      this.hideLoading()
    } catch (error) {
      console.error('Error loading stats:', error)
      this.hideLoading()
    }
  }

  updateMigrationWarning () {
    if (!this.hasMigrationWarningTarget) return

    const startDate = new Date(this.startDateTarget.value)
    const migrationDate = new Date('2025-01-01')

    if (startDate < migrationDate) {
      this.migrationWarningTarget.style.display = 'block'
    } else {
      this.migrationWarningTarget.style.display = 'none'
    }
  }

  updateSummaryCards (volume) {
    this.newRequestsCountTarget.textContent = volume.new_requests_submitted || 0
    this.reopeningsCountTarget.textContent = volume.reopenings_submitted || 0
    this.validationsCountTarget.textContent = volume.validations || 0
    this.refusalsCountTarget.textContent = volume.refusals || 0
  }

  updateDurationCards (durations) {
    this.percentile50TimeToSubmitTarget.textContent = this.formatDuration(durations.time_to_submit.percentile_50_seconds)
    this.percentile90TimeToSubmitTarget.textContent = this.formatDuration(durations.time_to_submit.percentile_90_seconds)

    this.percentile50TimeToFirstInstructionTarget.textContent = this.formatDuration(durations.time_to_first_instruction.percentile_50_seconds)
    this.percentile90TimeToFirstInstructionTarget.textContent = this.formatDuration(durations.time_to_first_instruction.percentile_90_seconds)

    this.percentile50TimeToFinalInstructionTarget.textContent = this.formatDuration(durations.time_to_final_instruction.percentile_50_seconds)
    this.percentile90TimeToFinalInstructionTarget.textContent = this.formatDuration(durations.time_to_final_instruction.percentile_90_seconds)
  }

  formatDuration (seconds) {
    if (!seconds || seconds === null || isNaN(seconds)) return 'N/A'

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
      return `${Math.floor(seconds)} seconde${seconds > 1 ? 's' : ''}`
    }
  }

  async updateTimeSeriesChart (timeSeries) {
    if (!this.hasTimeSeriesChartTarget || !timeSeries) return

    await this.loadChartJS()

    const labels = timeSeries.data.map(item => this.formatPeriodLabel(item.period, timeSeries.unit))
    const newRequestsAndReopeningsData = timeSeries.data.map(item => item.new_requests + item.reopenings)
    const completedInstructionsData = timeSeries.data.map(item => item.validations + item.refusals)

    if (this.timeSeriesChartInstance) {
      this.timeSeriesChartInstance.destroy()
    }

    const ctx = this.timeSeriesChartTarget.getContext('2d')
    this.timeSeriesChartInstance = new window.Chart(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [
          {
            label: 'Demandes soumises',
            data: newRequestsAndReopeningsData,
            backgroundColor: '#000091'
          },
          {
            label: 'Instructions terminées',
            data: completedInstructionsData,
            backgroundColor: '#18753c'
          }
        ]
      },
      options: {
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
            grid: {
              display: false
            }
          },
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      }
    })
  }

  formatPeriodLabel (period, unit) {
    const date = new Date(period)

    switch (unit) {
      case 'day':
        return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' })
      case 'week':
        return `Sem. ${this.getWeekNumber(date)} ${date.getFullYear()}`
      case 'month':
        return date.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
      case 'year':
        return date.getFullYear().toString()
      default:
        return period
    }
  }

  getWeekNumber (date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
    const dayNum = d.getUTCDay() || 7
    d.setUTCDate(d.getUTCDate() + 4 - dayNum)
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7)
  }

  loadChartJS () {
    return new Promise((resolve, reject) => {
      if (window.Chart) {
        resolve()
        return
      }

      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js'
      script.onload = () => {
        resolve()
      }
      script.onerror = () => {
        console.error('Failed to load Chart.js')
        reject(new Error('Failed to load Chart.js'))
      }
      document.head.appendChild(script)
    })
  }
}
