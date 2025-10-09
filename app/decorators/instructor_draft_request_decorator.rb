class InstructorDraftRequestDecorator < ApplicationDecorator
  delegate_all

  def obfuscated_applicant_email
    applicant.email.gsub(/(?<=.{2}).(?=.*@)/, '*')
  end
end
