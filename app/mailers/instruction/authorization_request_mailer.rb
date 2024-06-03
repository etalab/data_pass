class Instruction::AuthorizationRequestMailer < ApplicationMailer
  attr_reader :authorization_request

  def submitted
    @authorization_request = params[:authorization_request]

    return if instructors_or_reporters_to_notify.empty?

    mail(
      to: instructors_or_reporters_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  def reopening_submitted
    @authorization_request = params[:authorization_request]

    return if instructors_or_reporters_to_notify.empty?

    mail(
      to: instructors_or_reporters_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  private

  def instructors_or_reporters_to_notify
    @instructors_or_reporters_to_notify ||= instructors_or_reporters.reject do |user|
      !user.public_send(:"instruction_submit_notifications_for_#{authorization_request.definition.id.underscore}") &&
        user != authorization_request.applicant
    end
  end

  def instructors_or_reporters
    authorization_request.definition.instructors_or_reporters
  end
end
