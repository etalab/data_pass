class RecordProConnectDirigeantCertification < ApplicationInteractor
  def call
    context.user.organizations_users.find_by!(organization: context.organization)
      .update!(dirigeant_verified_at: context.verification[:verified_at])
  end
end
