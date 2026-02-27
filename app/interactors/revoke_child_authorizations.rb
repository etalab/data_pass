class RevokeChildAuthorizations < ApplicationInteractor
  def call
    return if context.authorization.auto_generated?

    active_child_authorizations.each do |child_authorization|
      RevokeAuthorization.call!(
        authorization: child_authorization,
        revocation_of_authorization_params: context.revocation_of_authorization_params,
        user: context.user
      )
    end
  end

  private

  def active_child_authorizations
    context.authorization.child_authorizations.select(&:active?)
  end
end
