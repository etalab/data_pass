class ClaimAuthorizationRequestInstructorDraftsController < AuthenticatedUserController
  allow_unauthenticated_access only: :show

  layout 'claim_authorization_request_instructor_draft'

  before_action :extract_authorization_request_instructor_draft
  before_action :ensure_draft_not_claimed!

  helper_method :obfuscated_applicant_email

  def show
    if user_signed_in?
      show_for_signed_in_user
    else
      show_for_guest_user
    end
  end

  def create
    organizer = ClaimAuthorizationRequestInstructorDraft.call(
      authorization_request_instructor_draft: @authorization_request_instructor_draft
    )

    if organizer.success?
      change_current_organization(organizer.organization) if organizer.organization != current_organization

      success_message(
        title: t('authorization_request_instructor_drafts.claim.success.title'),
      )

      redirect_to authorization_request_path(organizer.authorization_request)
    else
      error_message(
        title: t('authorization_request_instructor_drafts.claim.errors.generic.title'),
      )
      render 'show', status: :unprocessable_entity
    end
  end

  private

  def show_for_signed_in_user
    if @authorization_request_instructor_draft.applicant == current_user
      render 'show'
    else
      error_message(
        title: t('authorization_request_instructor_drafts.claim.errors.not_same_user.title'),
        description: t('authorization_request_instructor_drafts.claim.errors.not_same_user.description', obfuscated_email: obfuscated_applicant_email),
      )
      render 'denied'
    end
  end

  def show_for_guest_user
    session[:return_to_after_sign_in] = request.url

    render 'unauthenticated_show'
  end

  def ensure_draft_not_claimed!
    return unless @authorization_request_instructor_draft.claimed?

    error_message(
      title: t('authorization_request_instructor_drafts.claim.errors.already_claimed.title'),
      description: t('authorization_request_instructor_drafts.claim.errors.already_claimed.description'),
    )

    render 'denied'
  end

  def extract_authorization_request_instructor_draft
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find_by!(public_id: params[:id])
  end

  def change_current_organization(organization)
    current_user.organizations_users.find_by(organization:).set_as_current!
  end

  def obfuscated_applicant_email
    @authorization_request_instructor_draft.applicant.email.gsub(/(?<=.{2}).(?=.*@)/, '*')
  end

  def model_to_track_for_impersonation
    @authorization_request_instructor_draft
  end
end
