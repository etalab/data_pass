class APIEntreculierNotifier < BaseNotifier
  def approve(params)
    super

    RegisterOrganizationWithContactsOnCRMJob.perform_later(authorization_request.id)
  end
end
