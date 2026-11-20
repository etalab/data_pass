module WalletRegistryAnswer
  extend ActiveSupport::Concern

  ANSWERS = %w[dirigeant agent].freeze

  included do
    helper_method :wallet_registry_answer, :wallet_registry_change_answer_path, :wallet_registry_return_path
  end

  private

  def wallet_registry_answer
    params.fetch(:profil, nil).presence_in(ANSWERS)
  end

  def wallet_registry_answer_change?
    user_signed_in? && @authorization_definition.applicant_eligibility == 'wallet_registry' && params[:changer_de_reponse] == 'true'
  end

  def wallet_registry_change_answer_path
    new_authorization_request_path(definition_id: @authorization_definition.id, changer_de_reponse: (true if user_signed_in?))
  end

  def wallet_registry_return_path
    new_authorization_request_form_path(form_uid: @authorization_definition.available_forms.first.id, profil: wallet_registry_answer)
  end
end
