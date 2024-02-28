class Instruction::AuthorizationRequestMailer < ApplicationMailer
  def submitted
    @authorization_request = params[:authorization_request]

    mail(
      to: instructors_to_notify(@authorization_request).pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  private

  def instructors_to_notify(authorization_request)
    instructors(authorization_request.definition).reject do |instructor|
      !instructor.public_send(:"instruction_submit_notification_for_#{authorization_request.definition.id.underscore}") &&
        instructor != authorization_request.applicant
    end
  end

  def instructors(definition)
    definition.instructors
  end
end
