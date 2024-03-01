class MessageMailer < ApplicationMailer
  def to_applicant
    @authorization_request = params[:message].authorization_request

    mail(
      to: @authorization_request.applicant.email,
      subject: t('.subject', authorization_request_name: @authorization_request.name),
    )
  end

  def to_instructors
    @authorization_request = params[:message].authorization_request

    mail(
      to: @authorization_request.definition.instructors.pluck(:email),
      subject: t('.subject', authorization_request_name: @authorization_request.name),
    )
  end
end
