class Instruction::AuthorizationRequestMailer < ApplicationMailer
  attr_reader :authorization_request

  def submitted
    @authorization_request = params[:authorization_request]

    return if instructors_to_notify.empty?

    mail(
      to: instructors_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  def reopening_submitted
    @authorization_request = params[:authorization_request]

    return if instructors_to_notify.empty?

    mail(
      to: instructors_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  private

  def instructors_to_notify
    @instructors_to_notify ||= instructors.reject do |instructor|
      !instructor.public_send(:"instruction_submit_notifications_for_#{authorization_request.definition.id.underscore}") &&
        instructor != authorization_request.applicant
    end
  end

  def instructors
    authorization_request.definition.instructors
  end
end
