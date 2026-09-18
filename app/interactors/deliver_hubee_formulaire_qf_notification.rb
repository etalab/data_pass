class DeliverHubEEFormulaireQFNotification < ApplicationInteractor
  def call
    return unless authorization_request.formulaire_qf?
    return if already_formulaire_qf_before_reopening?
    return unless FeatureFlag.enabled?(:hubee_formulaire_qf_notification)

    HubEEMailer.with(authorization_request:).formulaire_qf_validation.deliver_later
  end

  private

  delegate :authorization_request, to: :context, private: true

  def already_formulaire_qf_before_reopening?
    return false unless within_reopening?
    return true if previous_authorization.nil?

    previous_authorization.request_as_validated(load_documents: false).formulaire_qf?
  end

  def within_reopening?
    (context.authorization_request_notifier_params || {})[:within_reopening]
  end

  def previous_authorization
    @previous_authorization ||= authorization_request.authorizations
      .where(authorization_request_class: authorization_request.class.name)
      .where.not(id: context.authorization&.id)
      .order(created_at: :desc)
      .first
  end
end
