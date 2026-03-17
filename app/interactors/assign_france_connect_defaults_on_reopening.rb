class AssignFranceConnectDefaultsOnReopening < ApplicationInteractor
  FC_ATTRIBUTES = %i[fc_eidas fc_cadre_juridique_nature fc_cadre_juridique_url].freeze

  def call
    return unless should_assign_defaults?

    assign_fc_attributes
    assign_fc_scopes
  end

  private

  delegate :authorization_request, to: :context, private: true

  def should_assign_defaults?
    authorization_request.is_a?(AuthorizationRequest::APIParticulier) &&
      authorization_request.france_connect_certified_form? &&
      authorization_request.france_connect_modality? &&
      authorization_request.reopening? &&
      authorization_request.france_connect_authorization_id.blank?
  end

  def assign_fc_attributes
    FC_ATTRIBUTES.each do |attr|
      next if authorization_request.public_send(attr).present?

      default_value = form_defaults[attr]
      authorization_request.public_send(:"#{attr}=", default_value) if default_value.present?
    end
  end

  def assign_fc_scopes
    current_scopes = authorization_request.scopes || []
    missing_scopes = france_connect_scope_values - current_scopes

    return if missing_scopes.empty?

    authorization_request.scopes = (current_scopes + missing_scopes)
  end

  def france_connect_scope_values
    AuthorizationRequest::APIParticulier.definition.scopes
      .select { |scope| scope.group == 'FranceConnect' }
      .map(&:value)
  end

  def form_defaults
    @form_defaults ||= authorization_request.form.initialize_with
  end
end
