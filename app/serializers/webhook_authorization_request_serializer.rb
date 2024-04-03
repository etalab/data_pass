class WebhookAuthorizationRequestSerializer < ApplicationSerializer
  attributes :id,
    :intitule,
    :description,
    :demarche,
    :status,
    :siret,
    :scopes,
    :team_members,
    :previous_authorization_request_id,
    :copied_from_authorization_request_id

  has_many(:events, serializer: WebhookEventSerializer) do
    object.events.map(&:decorate)
  end

  attribute :scopes do
    object.scopes.to_h { |scope| [scope.to_sym, true] }
  end

  def intitule    = object.data['intitule']
  def description = object.data['description']
  def demarche    = object.form.id
  def status      = object.state
  def siret       = object.organization.siret

  def team_members
    object.contacts.map { |contact|
      ContactSerializer.new(contact).serializable_hash
    } << applicant_as_team_member
  end

  def applicant_as_team_member
    {
      id: nil,
      type: 'demandeur',
      email: object.applicant.email,
      given_name: object.applicant.given_name,
      family_name: object.applicant.family_name,
      phone_number: object.applicant.phone_number,
      job: object.applicant.job_title,
    }
  end

  def previous_authorization_request_id = nil
  def copied_from_authorization_request_id = nil
end
