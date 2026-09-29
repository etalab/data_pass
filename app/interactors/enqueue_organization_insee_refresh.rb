class EnqueueOrganizationINSEERefresh < ApplicationInteractor
  def call
    return unless context.organization.insee_refresh_due?

    UpdateOrganizationINSEEPayloadJob.perform_later(context.organization.id)
  end
end
