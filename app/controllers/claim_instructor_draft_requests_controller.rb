class ClaimInstructorDraftRequestsController < AuthenticatedUserController
  allow_unauthenticated_access only: :show

  layout 'claim_instructor_draft_request'

  before_action :extract_instructor_draft_request
  before_action :ensure_draft_not_claimed!

  def show
    if user_signed_in?
      show_for_signed_in_user
    else
      show_for_guest_user
    end
  end

  def create
    organizer = ClaimInstructorDraftRequest.call(
      instructor_draft_request: @instructor_draft_request
    )

    if organizer.success?
      change_current_organization(organizer.organization) if organizer.organization != current_organization

      redirect_to authorization_request_path(organizer.authorization_request)
    else
      build_error_message(organizer)

      render 'show', status: :unprocessable_entity
    end
  end

  private

  def build_error_message(organizer)
    if I18n.exists?("instructor_draft_requests.claim.errors.#{organizer.error}.description")
      error_message(
        title: t("instructor_draft_requests.claim.errors.#{organizer.error}.title"),
        description: t("instructor_draft_requests.claim.errors.#{organizer.error}.description")
      )
    else
      error_message(
        title: t('instructor_draft_requests.claim.errors.generic.title'),
      )
    end
  end

  def show_for_signed_in_user
    if @instructor_draft_request.applicant == current_user
      render 'show'
    else
      error_message(
        title: t('instructor_draft_requests.claim.errors.not_same_user.title'),
        description: t('instructor_draft_requests.claim.errors.not_same_user.description', obfuscated_email: @instructor_draft_request.obfuscated_applicant_email),
      )
      render 'denied'
    end
  end

  def show_for_guest_user
    session[:return_to_after_sign_in] = request.url

    render 'unauthenticated_show'
  end

  def ensure_draft_not_claimed!
    return unless @instructor_draft_request.claimed?

    error_message(
      title: t('instructor_draft_requests.claim.errors.already_claimed.title'),
      description: t('instructor_draft_requests.claim.errors.already_claimed.description'),
    )

    render 'denied'
  end

  def extract_instructor_draft_request
    @instructor_draft_request = InstructorDraftRequest.find_by!(public_id: params[:id]).decorate
  end

  def change_current_organization(organization)
    current_user.organizations_users.find_by(organization:).set_as_current!
  end

  def model_to_track_for_impersonation
    @instructor_draft_request
  end
end
