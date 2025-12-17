# @label En-tête d'habilitation
class AuthorizationHeaderComponentPreview < ApplicationPreview
  # @label 1. Habilitation active
  def active
    authorization = Authorization.where(state: 'active').first!

    render AuthorizationHeaderComponent.new(authorization:, current_user: authorization.applicant)
  end

  # @label 2. Mention en tant que contact
  def contact_mention
    contact_user = User.find_by!(email: 'user@yopmail.com')
    authorization_request = AuthorizationRequest
      .where(state: 'validated')
      .where("EXISTS (
      select 1
      from each(authorization_requests.data) as kv
      where kv.key like '%_email' and lower(kv.value) = ?
    )", contact_user.email)
      .first!

    render AuthorizationHeaderComponent.new(authorization: authorization_request.latest_authorization, current_user: contact_user)
  end

  # @label 3. Habilitation obsolète
  def old_version
    authorization_request = AuthorizationRequest
      .joins(:authorizations)
      .group('authorization_requests.id')
      .having('count(authorizations.id) > 1')
      .first!

    old_authorization = authorization_request.authorizations.order(:created_at).first

    render AuthorizationHeaderComponent.new(authorization: old_authorization, current_user: authorization_request.applicant)
  end

  # @label 4. Habilitation révoquée
  def revoked
    authorization = Authorization.where(state: 'revoked').first!

    render AuthorizationHeaderComponent.new(authorization:, current_user: authorization.applicant)
  end
end
