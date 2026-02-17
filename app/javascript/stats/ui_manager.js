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
  if (loadingElement) loadingElement.style.display = 'block'
}

export function hideLoading (loadingElement) {
  if (loadingElement) loadingElement.style.display = 'none'
}

export function updateMigrationWarning (warningElement, startDateValue, migrationDateValue) {
  if (!warningElement) return

  const startDate = new Date(startDateValue)
  const migrationDate = new Date(migrationDateValue)

  warningElement.style.display = startDate < migrationDate ? 'block' : 'none'
}

export function showError (errorElement, message) {
  if (!errorElement) return

  errorElement.querySelector('p').textContent = message
  errorElement.style.display = 'block'
}

export function hideError (errorElement) {
  if (!errorElement) return

  errorElement.style.display = 'none'
}
