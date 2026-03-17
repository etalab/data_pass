class CreateLinkedFranceConnectAuthorization < ApplicationInteractor
  def call
    return unless should_create_linked_fc_authorization?

    context.linked_france_connect_authorization = create_fc_authorization!
    assign_fc_authorization_id_to_request!
    assign_fc_authorization_id_to_authorization!
    attach_documents!
  end

  private

  delegate :authorization, to: :context, private: true
  delegate :request, :applicant, to: :authorization, prefix: true, private: true
  delegate :data, to: :france_connect_data_builder, prefix: :france_connect, private: true

  def should_create_linked_fc_authorization?
    authorization_request.is_a?(AuthorizationRequest::APIParticulier) &&
      authorization_request.france_connect_certified_form? &&
      authorization_request.embeds_france_connect_fields? &&
      authorization_request.france_connect_authorization_id.blank?
  end

  def create_fc_authorization!
    Authorization.create!(
      request: authorization_request,
      applicant: authorization_applicant,
      authorization_request_class: 'AuthorizationRequest::FranceConnect',
      parent_authorization_id: authorization.id,
      data: france_connect_data,
      form_uid: authorization_request.form_uid
    )
  end

  def fc_authorization_id_data
    { 'france_connect_authorization_id' => context.linked_france_connect_authorization.id.to_s }
  end

  def assign_fc_authorization_id_to_request!
    authorization_request.update_columns( # rubocop:disable Rails/SkipsModelValidations
      data: authorization_request.data.merge(fc_authorization_id_data)
    )
    authorization_request.reload
  end

  def assign_fc_authorization_id_to_authorization!
    context.authorization.update_columns( # rubocop:disable Rails/SkipsModelValidations
      data: context.authorization.data.merge(fc_authorization_id_data)
    )
    context.authorization.reload
  end

  def attach_documents!
    france_connect_data_builder.attach_documents_to(context.linked_france_connect_authorization)
  end

  def france_connect_data_builder
    @france_connect_data_builder ||= FranceConnectDataBuilder.new(authorization_request)
  end
end
