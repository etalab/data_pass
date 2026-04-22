class EnqueueOrganizationINSEERefresh < ApplicationInteractor
  def call
    UpdateOrganizationINSEEPayloadJob.perform_later(context.organization.id)
  end
end
