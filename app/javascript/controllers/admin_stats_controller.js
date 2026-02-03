import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'startDate',
    'endDate',
    'providerSelect',
    'typeSelect',
    'formSelect',
    'dimensionSelect',
    'newRequestsCount',
    'reopeningsCount',
    'validationsCount',
    'refusalsCount',
    'medianTimeToSubmit',
    'stddevTimeToSubmit',
    'medianTimeToFirstInstruction',
    'stddevTimeToFirstInstruction',
    'medianTimeToFinalInstruction',
    'stddevTimeToFinalInstruction',
    'volumeBreakdownChart',
    'timeToSubmitBreakdownChart',
    'timeToFirstInstructionBreakdownChart',
    'timeToFinalInstructionBreakdownChart',
    'loadingIndicator',
    'breakdownSection',
    'quickRanges',
    'migrationWarning'
  ]

  connect () {
    this.charts = {}
    this.allProviders = []
    this.allTypes = []
    this.allForms = []
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
    lastYearBtn.dataset.action = 'click->admin-stats#setDateRange'
    lastYearBtn.dataset.range = `year-${lastYear}`
    lastYearBtn.textContent = `Année ${lastYear}`

    const currentYearBtn = document.createElement('button')
    currentYearBtn.className = 'fr-btn fr-btn--sm fr-btn--tertiary-no-outline'
    currentYearBtn.type = 'button'
    currentYearBtn.dataset.action = 'click->admin-stats#setDateRange'
    currentYearBtn.dataset.range = `year-${currentYear}`
    currentYearBtn.textContent = `Année ${currentYear}`

    this.quickRangesTarget.appendChild(lastYearBtn)
    this.quickRangesTarget.appendChild(currentYearBtn)
  }

  disconnect () {
    Object.values(this.charts).forEach(chart => chart.destroy())
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

    if (params.has('dimension')) {
      this.dimensionSelectTarget.value = params.get('dimension')
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

    params.set('dimension', this.dimensionSelectTarget.value)

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

      this.loadData()
    } catch (error) {
      console.error('Error loading filter options:', error)
      this.loadData()
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

    if (params.has('dimension')) {
      this.dimensionSelectTarget.value = params.get('dimension')
    } else {
      this.updateDimensionSelector()
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

    if (currentValue && Array.from(this.typeSelectTarget.options).some(opt => opt.value === currentValue)) {
      this.typeSelectTarget.value = currentValue
    }
  }

  populateFormSelect () {
    const selectedProviders = this.getSelectedProviders()
    const selectedTypes = this.getSelectedTypes()
    const currentValue = this.formSelectTarget.value
    this.formSelectTarget.innerHTML = '<option value="">Tous les formulaires</option>'

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
    const endDate = new Date()
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 1)

    this.startDateTarget.valueAsDate = startDate
    this.endDateTarget.valueAsDate = endDate

    this.providerSelectTarget.value = ''
    this.typeSelectTarget.value = ''
    this.formSelectTarget.value = ''

    this.dimensionSelectTarget.value = 'provider'

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
        case 'last-6-months':
          startDate = new Date(today)
          startDate.setMonth(startDate.getMonth() - 6)
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
    const offset = date.getTimezoneOffset()
    const localDate = new Date(date.getTime() - (offset * 60 * 1000))
    return localDate.toISOString().split('T')[0]
  }

  async updateFilters () {
    this.populateTypeSelect()
    this.populateFormSelect()

    this.updateDimensionSelector()

    this.updateBreakdownSectionVisibility()

    this.highlightActiveQuickRange()

    this.updateURL()

    await this.loadData()
  }

  updateBreakdownSectionVisibility () {
    const selectedForms = this.getSelectedForms()

    if (this.hasBreakdownSectionTarget) {
      if (selectedForms.length > 0) {
        this.breakdownSectionTarget.style.display = 'none'
      } else {
        this.breakdownSectionTarget.style.display = 'block'
      }
    }
  }

  async updateDimension () {
    this.updateURL()
    await this.loadData()
  }

  updateDimensionSelector () {
    const selectedProviders = this.getSelectedProviders()
    const selectedTypes = this.getSelectedTypes()
    const selectedForms = this.getSelectedForms()

    let newDimension = 'provider'

    if (selectedTypes.length === 1 || selectedForms.length > 0) {
      newDimension = 'form'
    } else if (selectedProviders.length === 1 || selectedTypes.length > 0) {
      newDimension = 'type'
    }

    this.dimensionSelectTarget.value = newDimension
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

      const response = await fetch(`/admin/stats/data?${params}`)
      const data = await response.json()

      this.updateSummaryCards(data.volume)
      this.updateDurationCards(data.durations)
      await this.updateBreakdownCharts(data.breakdowns, data.dimension)

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
    this.medianTimeToSubmitTarget.textContent = this.formatDuration(durations.time_to_submit.median_seconds)
    this.stddevTimeToSubmitTarget.textContent = this.formatDuration(
      durations.time_to_submit.median_seconds + (durations.time_to_submit.stddev_seconds / 2)
    )

    this.medianTimeToFirstInstructionTarget.textContent = this.formatDuration(durations.time_to_first_instruction.median_seconds)
    this.stddevTimeToFirstInstructionTarget.textContent = this.formatDuration(
      durations.time_to_first_instruction.median_seconds + (durations.time_to_first_instruction.stddev_seconds / 2)
    )

    this.medianTimeToFinalInstructionTarget.textContent = this.formatDuration(durations.time_to_final_instruction.median_seconds)
    this.stddevTimeToFinalInstructionTarget.textContent = this.formatDuration(
      durations.time_to_final_instruction.median_seconds + (durations.time_to_final_instruction.stddev_seconds / 2)
    )
  }

  async updateBreakdownCharts (breakdowns, dimension) {
    if (!breakdowns) {
      return
    }

    try {
      if (breakdowns.volume && breakdowns.volume.length > 0) {
        await this.createHorizontalBarChart(
          this.volumeBreakdownChartTarget,
          'volumeBreakdown',
          breakdowns.volume,
          'Nombre de demandes'
        )
      }

      if (breakdowns.time_to_submit && breakdowns.time_to_submit.length > 0) {
        await this.createDurationBarChart(
          this.timeToSubmitBreakdownChartTarget,
          'timeToSubmitBreakdown',
          breakdowns.time_to_submit,
          'Durée médiane (secondes)'
        )
      }

      if (breakdowns.time_to_first_instruction && breakdowns.time_to_first_instruction.length > 0) {
        await this.createDurationBarChart(
          this.timeToFirstInstructionBreakdownChartTarget,
          'timeToFirstInstructionBreakdown',
          breakdowns.time_to_first_instruction,
          'Durée médiane (secondes)'
        )
      }

      if (breakdowns.time_to_final_instruction && breakdowns.time_to_final_instruction.length > 0) {
        await this.createDurationBarChart(
          this.timeToFinalInstructionBreakdownChartTarget,
          'timeToFinalInstructionBreakdown',
          breakdowns.time_to_final_instruction,
          'Durée médiane (secondes)'
        )
      }
    } catch (error) {
      console.error('Error creating breakdown charts:', error)
    }
  }

  async createHorizontalBarChart (canvas, chartId, data, label) {
    if (this.charts[chartId]) {
      this.charts[chartId].destroy()
    }

    if (!window.Chart) {
      await this.loadChartJS()
    }

    const labels = data.map(item => item.label)
    const values = data.map(item => item.value)
    const percentages = data.map(item => item.percentage)

    this.charts[chartId] = new window.Chart(canvas, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label,
          data: values,
          backgroundColor: '#000091',
          borderColor: '#000091',
          borderWidth: 1
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: function (context) {
                const index = context.dataIndex
                return `${context.parsed.x} (${percentages[index]}%)`
              }
            }
          }
        },
        scales: {
          x: {
            beginAtZero: true
          }
        }
      }
    })
  }

  async createDurationBarChart (canvas, chartId, data, label) {
    if (this.charts[chartId]) {
      this.charts[chartId].destroy()
    }

    if (!window.Chart) {
      await this.loadChartJS()
    }

    const labels = data.map(item => item.label)
    const values = data.map(item => item.value)

    this.charts[chartId] = new window.Chart(canvas, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label,
          data: values,
          backgroundColor: '#18753C',
          borderColor: '#18753C',
          borderWidth: 1
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                return this.formatDuration(context.parsed.x)
              }
            }
          }
        },
        scales: {
          x: {
            beginAtZero: true,
            ticks: {
              callback: (value) => {
                return this.formatDuration(value)
              }
            }
          }
        }
      }
    })
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
