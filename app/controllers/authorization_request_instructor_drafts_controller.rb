class AuthorizationRequestInstructorDraftsController < ApplicationController
  def claim
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find_by!(public_id: params[:id])
  end
end
