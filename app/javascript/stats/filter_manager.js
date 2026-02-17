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

export function updateURL (startDate, endDate, provider, type, form) {
  const params = new URLSearchParams()

  params.set('start_date', startDate)
  params.set('end_date', endDate)
  if (provider) params.set('provider', provider)
  if (type) params.set('type', type)
  if (form) params.set('form', form)

  const newURL = `${window.location.pathname}?${params.toString()}`
  window.history.pushState({}, '', newURL)
}

export function restoreFiltersFromURL (providerSelect, typeSelect, formSelect, populateTypeSelect, populateFormSelect) {
  const params = new URLSearchParams(window.location.search)

  if (params.has('provider')) {
    providerSelect.value = params.get('provider')
    populateTypeSelect()
  }

  if (params.has('type')) {
    typeSelect.value = params.get('type')
    populateFormSelect()
  }

  if (params.has('form')) {
    formSelect.value = params.get('form')
  }
}

export function populateProviderSelect (selectElement, providers) {
  selectElement.innerHTML = '<option value="">Tous les fournisseurs</option>'
  providers.forEach(provider => {
    const option = document.createElement('option')
    option.value = provider.slug
    option.textContent = provider.name
    selectElement.appendChild(option)
  })
}

export function populateTypeSelect (selectElement, allTypes, selectedProviders) {
  const currentValue = selectElement.value
  selectElement.innerHTML = '<option value="">Tous les types</option>'

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

export function populateFormSelect (selectElement, allForms, selectedProviders, selectedTypes) {
  const currentValue = selectElement.value
  selectElement.innerHTML = '<option value="">Tous les formulaires</option>'

  if (selectedProviders.length === 0 || selectedTypes.length === 0) {
    selectElement.disabled = true
    return
  }

  selectElement.disabled = false

  const filteredForms = allForms.filter(form => selectedTypes.includes(form.authorization_type))

  filteredForms.forEach(form => {
    const option = document.createElement('option')
    option.value = form.uid
    option.textContent = form.name
    selectElement.appendChild(option)
  })

  if (currentValue && Array.from(selectElement.options).some(opt => opt.value === currentValue)) {
    selectElement.value = currentValue
  }
}
