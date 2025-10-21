class CheckApplicantBelongsToOrganization < ApplicationInteractor
  def call
    return if context.new_applicant.organizations.include?(context.new_organization)

    context.fail!(error: :applicant_not_in_organization)
  end
end
