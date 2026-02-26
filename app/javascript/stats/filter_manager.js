import { formatDate } from 'stats/date_utils'

export function loadFiltersFromURL (startDateTarget, endDateTarget) {
  const params = new URLSearchParams(window.location.search)

  if (params.has('start_date')) {
    startDateTarget.value = params.get('start_date')
  } else {
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 1)
    startDateTarget.value = formatDate(startDate)
  }

  if (params.has('end_date')) {
    endDateTarget.value = params.get('end_date')
  } else {
    endDateTarget.value = formatDate(new Date())
  }
}

export function updateURL (startDate, endDate, provider, type) {
  const params = new URLSearchParams()

  params.set('start_date', startDate)
  params.set('end_date', endDate)
  if (provider) params.set('provider', provider)
  if (type) params.set('type', type)

  const newURL = `${window.location.pathname}?${params.toString()}`
  window.history.pushState({}, '', newURL)
}

export function restoreFiltersFromURL (providerSelect, typeSelect, populateTypeSelect) {
  const params = new URLSearchParams(window.location.search)

  if (params.has('provider')) {
    providerSelect.value = params.get('provider')
    populateTypeSelect()
  }

  if (params.has('type')) {
    typeSelect.value = params.get('type')
  }
}

export function populateProviderSelect (selectElement, providers, allProvidersLabel) {
  selectElement.innerHTML = `<option value="">${allProvidersLabel}</option>`
  providers.forEach(provider => {
    const option = document.createElement('option')
    option.value = provider.slug
    option.textContent = provider.name
    selectElement.appendChild(option)
  })
}

export function populateTypeSelect (selectElement, allTypes, selectedProviders, allDefinitionsLabel) {
  const currentValue = selectElement.value
  selectElement.innerHTML = `<option value="">${allDefinitionsLabel}</option>`

  if (selectedProviders.length === 0) {
    selectElement.disabled = true
    return
  }

  selectElement.disabled = false

  const filteredTypes = allTypes.filter(type => selectedProviders.includes(type.provider_slug))

  filteredTypes.forEach(type => {
    const option = document.createElement('option')
    option.value = type.class_name
    option.textContent = type.name
    selectElement.appendChild(option)
  })

  if (currentValue && Array.from(selectElement.options).some(opt => opt.value === currentValue)) {
    selectElement.value = currentValue
  }
}
