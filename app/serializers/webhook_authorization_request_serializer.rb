class WebhookAuthorizationRequestSerializer < ApplicationSerializer
  attributes :id,
    :intitule,
    :description,
    :demarche,
    :status,
    :siret,
    :scopes,
    :previous_authorization_request_id,
    :copied_from_authorization_request_id

  has_many(:contacts, serializer: ContactSerializer)
  has_many(:events, serializer: WebhookEventSerializer)

  attribute :scopes do
    object.scopes.to_h { |scope| [scope.to_sym, true] }
  end

  def demarche = object.form.name
  def status   = object.state
  def siret    = object.organization.siret
  def events = object.events.map(&:decorate)

  # TODO: remove both once authorization_request copies are implemented
  def previous_authorization_request_id = nil
  def copied_from_authorization_request_id = nil
end