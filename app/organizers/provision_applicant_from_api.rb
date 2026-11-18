class ProvisionApplicantFromAPI < ApplicationOrganizer
  include TransactionalOrganizer

  before do
    context.identity_federator = 'unknown'
  end

  organize FindOrCreateApplicantFromAPI,
    FindOrCreateOrganizationForAPI,
    LinkApplicantToOrganization
end
