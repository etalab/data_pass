require 'rails_helper'

RSpec.describe Molecules::Instruction::EntityEligibilityVerdictComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(verdict:)) }

  let(:verdict) { EntityEligibility::Verdict.new(status:, reason:) }

  context 'when the verdict is eligible' do
    let(:status) { :eligible }
    let(:reason) { :administration }

    it 'renders a success callout labelled « Valide » with the rule explanation' do
      expect(rendered).to have_css('div.fr-callout.eligibility-callout--success .fr-callout__title', text: 'Valide')
      expect(rendered).to have_text('Administration')
    end
  end

  context 'when the verdict is likely_eligible' do
    let(:status) { :likely_eligible }
    let(:reason) { :public_commercial }

    it 'renders an info callout labelled « L’organisation semble éligible » with the rule explanation' do
      expect(rendered).to have_css('div.fr-callout.eligibility-callout--info .fr-callout__title', text: 'L’organisation semble éligible')
      expect(rendered).to have_text('Entité publique à caractère commercial')
    end
  end

  context 'when the verdict is likely_ineligible' do
    let(:status) { :likely_ineligible }
    let(:reason) { :not_a_commune }

    it 'renders a warning callout labelled « Invalide (à confirmer) » with the rule explanation' do
      expect(rendered).to have_css('div.fr-callout.eligibility-callout--warning .fr-callout__title', text: 'Invalide (à confirmer)')
      expect(rendered).to have_text('n’est pas une commune')
    end
  end

  context 'when the verdict is ineligible' do
    let(:status) { :ineligible }
    let(:reason) { :not_administration }

    it 'renders an error callout labelled « Invalide » with the rule explanation' do
      expect(rendered).to have_css('div.fr-callout.eligibility-callout--error .fr-callout__title', text: 'Invalide')
      expect(rendered).to have_text('Ni administration')
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
