import { Controller } from '@hotwired/stimulus'
import { formatDate, calculateRangeDates } from 'stats/date_utils'
import * as filterManager from 'stats/filter_manager'
import * as dataManager from 'stats/data_manager'
import * as ui from 'stats/ui_manager'

export default class extends Controller {
  static DEBOUNCE_DELAY_MS = 1000
  static targets = [
    'startDate', 'endDate', 'providerSelect', 'typeSelect', 'formSelect',
    'totalRequestsCount', 'reopeningsCount', 'validationsCount', 'refusalsCount',
    'percentile50TimeToSubmit', 'percentile90TimeToSubmit',
    'percentile50TimeToFirstInstruction', 'percentile90TimeToFirstInstruction',
    'percentile50TimeToFinalInstruction', 'percentile90TimeToFinalInstruction',
    'loadingIndicator', 'quickRanges', 'timeSeriesChart', 'migrationWarning', 'errorAlert'
  ]

  static values = { migrationDate: { type: String, default: '2025-01-01' } }

  connect () {
    this.allProviders = []
    this.allTypes = []
    this.allForms = []
    this.timeSeriesChartInstance = null
    this.isInitializing = true
    this.debounceTimeout = null
    this.currentAbortController = null
    filterManager.loadFiltersFromURL(this.startDateTarget, this.endDateTarget)
    ui.highlightActiveQuickRange(this.quickRangesTarget, this.startDateTarget.value, this.endDateTarget.value)
    this.loadFilterOptions()
  }

  disconnect () {
    if (this.debounceTimeout) clearTimeout(this.debounceTimeout)
    if (this.currentAbortController) this.currentAbortController.abort()
    if (this.timeSeriesChartInstance) this.timeSeriesChartInstance.destroy()
  }

  async loadFilterOptions () {
    try {
      const filtersData = await dataManager.fetchFilterOptions()
      this.allProviders = filtersData.providers || []
      this.allTypes = filtersData.types || []
      this.allForms = filtersData.forms || []

      filterManager.populateProviderSelect(this.providerSelectTarget, this.allProviders)
      this.refreshTypeSelect()
      this.refreshFormSelect()
      filterManager.restoreFiltersFromURL(
        this.providerSelectTarget, this.typeSelectTarget, this.formSelectTarget,
        () => this.refreshTypeSelect(), () => this.refreshFormSelect()
      )
      this.isInitializing = false
      await this.loadData()
    } catch (error) {
      this.isInitializing = false
      ui.showError(this.errorElement, 'Impossible de charger les filtres. Veuillez réessayer.')
    }
  }

  clearFilters () {
    const endDate = new Date()
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 1)
    this.startDateTarget.value = formatDate(startDate)
    this.endDateTarget.value = formatDate(endDate)
    this.providerSelectTarget.value = ''
    this.typeSelectTarget.value = ''
    this.formSelectTarget.value = ''
    this.updateFilters()
  }

  setDateRange (event) {
    const { startDate, endDate } = calculateRangeDates(event.currentTarget.dataset.range)
    if (!startDate || !endDate) return
    this.startDateTarget.value = formatDate(startDate)
    this.endDateTarget.value = formatDate(endDate)
    this.updateFilters()
  }

  updateFiltersDebounced () {
    if (this.isInitializing) return
    if (this.debounceTimeout) clearTimeout(this.debounceTimeout)
    this.debounceTimeout = setTimeout(() => this.updateFilters(), this.constructor.DEBOUNCE_DELAY_MS)
  }

  async updateFilters () {
    if (this.isInitializing) return
    this.refreshTypeSelect()
    this.refreshFormSelect()
    ui.highlightActiveQuickRange(this.quickRangesTarget, this.startDateTarget.value, this.endDateTarget.value)
    filterManager.updateURL(
      this.startDateTarget.value, this.endDateTarget.value,
      this.providerSelectTarget.value, this.typeSelectTarget.value, this.formSelectTarget.value
    )
    await this.loadData()
  }

  async loadData () {
    if (this.currentAbortController) this.currentAbortController.abort()
    this.currentAbortController = new AbortController()
    try {
      ui.showLoading(this.loadingElement)
      ui.hideError(this.errorElement)
      ui.updateMigrationWarning(this.migrationElement, this.startDateTarget.value, this.migrationDateValue)
      const data = await dataManager.fetchStatsData(
        this.startDateTarget.value, this.endDateTarget.value,
        this.selectedProviders, this.selectedTypes, this.selectedForms,
        this.currentAbortController.signal
      )
      dataManager.updateSummaryCards(this.summaryTargets, data.volume)
      this.timeSeriesChartInstance = dataManager.updateTimeSeriesChart(
        this.hasTimeSeriesChartTarget ? this.timeSeriesChartTarget : null,
        data.time_series, this.timeSeriesChartInstance
      )
      dataManager.updateDurationCards(this.durationTargets, data.durations)
      ui.hideLoading(this.loadingElement)
    } catch (error) {
      if (error.name === 'AbortError') return
      ui.hideLoading(this.loadingElement)
      ui.showError(this.errorElement, 'Impossible de charger les statistiques. Veuillez réessayer.')
    }
  }

  get loadingElement () { return this.hasLoadingIndicatorTarget ? this.loadingIndicatorTarget : null }
  get errorElement () { return this.hasErrorAlertTarget ? this.errorAlertTarget : null }
  get migrationElement () { return this.hasMigrationWarningTarget ? this.migrationWarningTarget : null }
  get selectedProviders () { return this.providerSelectTarget.value ? [this.providerSelectTarget.value] : [] }
  get selectedTypes () { return this.typeSelectTarget.value ? [this.typeSelectTarget.value] : [] }
  get selectedForms () { return this.formSelectTarget.value ? [this.formSelectTarget.value] : [] }

  get summaryTargets () {
    return ['totalRequestsCount', 'reopeningsCount', 'validationsCount', 'refusalsCount']
      .reduce((acc, key) => ({ ...acc, [key]: this[`${key}Target`] }), {})
  }

  get durationTargets () {
    return ['TimeToSubmit', 'TimeToFirstInstruction', 'TimeToFinalInstruction']
      .reduce((acc, key) => ({
        ...acc,
        [`percentile50${key}`]: this[`percentile50${key}Target`],
        [`percentile90${key}`]: this[`percentile90${key}Target`]
      }), {})
  }

  refreshTypeSelect () {
    filterManager.populateTypeSelect(this.typeSelectTarget, this.allTypes, this.selectedProviders)
  }

  refreshFormSelect () {
    filterManager.populateFormSelect(this.formSelectTarget, this.allForms, this.selectedProviders, this.selectedTypes)
  }
}
