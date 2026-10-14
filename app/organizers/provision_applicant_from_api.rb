class ProvisionApplicantFromAPI < ApplicationOrganizer
  before do
    context.identity_federator = 'unknown'
  end

  organize FindOrCreateApplicantFromAPI,
    FindOrCreateOrganizationForAPI,
    LinkApplicantToOrganization
end
