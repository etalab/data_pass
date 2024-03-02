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
      to: instructors_to_notify(@authorization_request).pluck(:email),
      subject: t('.subject', authorization_request_name: @authorization_request.name),
    )
  end

  private

  def instructors_to_notify(authorization_request)
    instructors(authorization_request.definition).reject do |instructor|
      !instructor.public_send(:"instruction_messages_notifications_for_#{authorization_request.definition.id.underscore}") &&
        instructor != authorization_request.applicant
    end
  end

  def instructors(definition)
    definition.instructors
  end
end
