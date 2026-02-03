import StatsController from './stats_controller'

export default class extends StatsController {
  static targets = [
    ...StatsController.targets,
    'dimensionSelect',
    'volumeBreakdownChart',
    'timeToSubmitBreakdownChart',
    'timeToFirstInstructionBreakdownChart',
    'timeToFinalInstructionBreakdownChart',
    'breakdownSection'
  ]

  connect () {
    this.charts = {}
    super.connect()
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
    super.loadFiltersFromURL()

    const params = new URLSearchParams(window.location.search)

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

  restoreFiltersFromURL () {
    super.restoreFiltersFromURL()

    const params = new URLSearchParams(window.location.search)

    if (params.has('dimension')) {
      this.dimensionSelectTarget.value = params.get('dimension')
    } else {
      this.updateDimensionSelector()
    }
  }

  clearFilters () {
    super.clearFilters()
    this.dimensionSelectTarget.value = 'provider'
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

  async updateFilters () {
    if (this.isInitializing) {
      return
    }

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
}
