class Molecules::AuthorizationRequestForms::EntityEligibilityIntroComponentPreview < ViewComponent::Preview
  def eligible
    render_verdict(:eligible, nil)
  end

  def likely_eligible
    render_verdict(:likely_eligible, :public_commercial)
  end

  def likely_ineligible
    render_verdict(:likely_ineligible, :not_a_commune)
  end

  def ineligible
    render_verdict(:ineligible, :menuiserie)
  end

  def unknown
    render_verdict(:unknown, nil)
  end

  private

  def render_verdict(status, reason)
    render Molecules::AuthorizationRequestForms::EntityEligibilityIntroComponent.new(
      verdict: EntityEligibility::Verdict.new(status:, reason:),
      authorization_request_form: AuthorizationRequestForm.find('api-entreprise'),
    )
  end
end
