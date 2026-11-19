class WalletRegistry::SubmissionsController < AuthorizationRequestFormsController
  skip_before_action :guard_wallet_registry_start
  before_action :extract_authorization_request

  def create
    authorize @authorization_request, :submit_as_executive?

    organizer = StartWalletExecutiveSubmission.call(authorization_request: @authorization_request, authorization_request_params:, user: current_user)

    if organizer.success?
      session[WalletRegistry::SubmissionIntent::SESSION_KEY] = organizer.submission_intent.to_session
      @return_path = complete_wallet_registry_submission_path(form_uid: @authorization_request.form_uid, authorization_request_id: @authorization_request.id, nonce: organizer.submission_intent.nonce)

      render :create, layout: 'container'
    else
      render_submit_failure
    end
  end

  def complete
    authorize @authorization_request, :submit_as_executive?

    organizer = CompleteWalletExecutiveSubmission.call(**completion_context)
    @authorization_request = organizer.authorization_request

    if organizer.success?
      clean_wizard_step!
      success_message_for_authorization_request(@authorization_request, key: submit_message_key)

      redirect_to dashboard_path
    else
      @wallet_submission_refusal = wallet_submission_refusal(organizer.error)
      render_submit_failure
    end
  end

  private

  def completion_context
    {
      authorization_request: @authorization_request,
      user: current_user,
      nonce: params[:nonce],
      submission_intent: WalletRegistry::SubmissionIntent.from_session(session.delete(WalletRegistry::SubmissionIntent::SESSION_KEY)),
      dirigeant_verification: pundit_user.dirigeant_verification,
    }
  end

  def wallet_submission_refusal(error)
    case error.try(:dig, :key)
    when :wallet_submission_intent_invalid then :resume
    when :wallet_executive_not_certified then :executive_not_certified
    end
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class
      .includes(:organization)
      .find(params.expect(:authorization_request_id))
      .decorate
  end
end
