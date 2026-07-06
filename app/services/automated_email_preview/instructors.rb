class AutomatedEmailPreview::Instructors < AutomatedEmailPreview
  SampleInstructor = Struct.new(:id, :email)

  def subject
    I18n.t('instruction.authorization_request_mailer.submit.subject')
  end

  private

  def body_template
    'instruction/authorization_request_mailer/submit'
  end

  def assigns
    super.merge(user: SampleInstructor.new(0, '[email de l’instructeur]'))
  end
end
