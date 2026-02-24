import { formatDate, calculateRangeDates } from 'stats/date_utils'

export function highlightActiveQuickRange (quickRangesElement, currentStart, currentEnd) {
  const buttons = quickRangesElement.querySelectorAll('button')

  buttons.forEach(button => {
    const range = button.dataset.range
    const { startDate, endDate } = calculateRangeDates(range)
    const isActive = startDate && endDate &&
      formatDate(startDate) === currentStart && formatDate(endDate) === currentEnd

    button.classList.toggle('fr-btn--secondary', isActive)
    button.classList.toggle('fr-btn--tertiary-no-outline', !isActive)
  })
}

export function showLoading (loadingElement) {
  if (!loadingElement) return
  loadingElement.classList.add('fr-modal--opened')
}

export function hideLoading (loadingElement) {
  if (!loadingElement) return
  loadingElement.classList.remove('fr-modal--opened')
}

export function updateMigrationWarning (warningElement, startDateValue, migrationDateValue) {
  if (!warningElement) return

  const startDate = new Date(startDateValue)
  const migrationDate = new Date(migrationDateValue)

  warningElement.classList.toggle('fr-hidden', startDate >= migrationDate)
}

export function showError (errorElement, message) {
  if (!errorElement) return

  errorElement.querySelector('p').textContent = message
  errorElement.classList.remove('fr-hidden')
}

export function hideError (errorElement) {
  if (!errorElement) return

  errorElement.classList.add('fr-hidden')
}
