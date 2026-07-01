require 'rails_helper'

RSpec.describe Molecules::AuthorizationRequestForms::EntityEligibilityIntroComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(verdict:, authorization_request_form:)) }

  let(:verdict) { EntityEligibility::Verdict.new(status:, reason:) }
  let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }

  context 'when the verdict is eligible' do
    let(:status) { :eligible }
    let(:reason) { nil }

    it 'announces the automatic approval' do
      expect(rendered).to have_css('.entity-eligibility-intro--auto')
      expect(rendered).to have_text('approuvée automatiquement')
    end
  end

  context 'when the verdict is likely_eligible' do
    let(:status) { :likely_eligible }
    let(:reason) { :public_commercial }

    it 'renders an info hint' do
      expect(rendered).to have_css('.entity-eligibility-intro--info')
      expect(rendered).to have_text('semble éligible')
    end
  end

  context 'when the verdict is likely_ineligible' do
    let(:status) { :likely_ineligible }
    let(:reason) { :not_a_commune }

    it 'renders a warning hint' do
      expect(rendered).to have_css('.entity-eligibility-intro--warning')
    end
  end

  context 'when the verdict is ineligible' do
    let(:status) { :ineligible }
    let(:reason) { :menuiserie }

    it 'renders the blocking block with the rule-specific reason and the provider contact' do
      expect(rendered).to have_css('.entity-eligibility-intro__block')
      expect(rendered).to have_text('D’après son activité déclarée (menuiserie)')
      expect(rendered).to have_link(href: 'mailto:support@entreprise.api.gouv.fr')
    end
  end

  context 'when the reason has no rule-specific override' do
    let(:authorization_request_form) { AuthorizationRequestForm.find('aide-financiere') }
    let(:status) { :ineligible }
    let(:reason) { :not_administration }

    it 'falls back to the base reason wording' do
      expect(rendered).to have_text('D’après sa catégorie juridique')
    end
  end

  context 'when the verdict is unknown' do
    let(:status) { :unknown }
    let(:reason) { nil }

    it 'renders nothing' do
      expect(rendered.to_html).to be_blank
    end
  end
end
