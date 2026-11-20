module WalletRegistryAnswer
  extend ActiveSupport::Concern

  ANSWERS = %w[dirigeant agent].freeze

  included do
    helper_method :wallet_registry_change_answer_path
  end

  private

  def wallet_registry_answer
    params.fetch(:parcours, nil).presence_in(ANSWERS)
  end

  def wallet_registry_answer_change?
    user_signed_in? && @authorization_definition.wallet_registry? && params[:changer_de_reponse] == 'true'
  end

  def wallet_registry_change_answer_path
    new_authorization_request_path(definition_id: @authorization_definition.id, changer_de_reponse: (true if user_signed_in?))
  end

  def build_wallet_registry_sign_in(violation: nil)
    WalletRegistrySignIn.new(answer: wallet_registry_answer, violation:, signed_in: user_signed_in?, organization: current_organization, return_to: wallet_registry_return_path)
  end

  def wallet_registry_return_path
    authorization_request_form_introduction_path(form_uid: @authorization_definition.available_forms.first.id, parcours: wallet_registry_answer)
  end
end
