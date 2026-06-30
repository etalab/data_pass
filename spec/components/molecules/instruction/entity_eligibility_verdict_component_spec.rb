require 'rails_helper'

RSpec.describe Molecules::Instruction::EntityEligibilityVerdictComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(verdict:)) }

  let(:verdict) { EntityEligibility::Verdict.new(status:, reason:) }

  context 'when the verdict is eligible' do
    let(:status) { :eligible }
    let(:reason) { :administration }

    it 'renders a success badge labelled « Valide » with the rule explanation' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--success', text: 'Valide')
      expect(rendered).to have_text('Administration')
    end
  end

  context 'when the verdict is likely_eligible' do
    let(:status) { :likely_eligible }
    let(:reason) { :public_commercial }

    it 'renders an info badge labelled « Valide (à confirmer) » with the rule explanation' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--info', text: 'Valide (à confirmer)')
      expect(rendered).to have_text('Entité publique à caractère commercial')
    end
  end

  context 'when the verdict is ineligible' do
    let(:status) { :ineligible }
    let(:reason) { :not_administration }

    it 'renders an error badge labelled « Invalide » with the rule explanation' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--error', text: 'Invalide')
      expect(rendered).to have_text('Ni administration')
    end
  end

  context 'when the verdict is unknown' do
    let(:status) { :unknown }
    let(:reason) { nil }

    it 'renders a neutral badge without a semantic modifier' do
      expect(rendered).to have_css('p.fr-badge', text: 'Éligibilité indéterminée')
      expect(rendered).to have_no_css('.fr-badge--success, .fr-badge--error, .fr-badge--info, .fr-badge--warning')
      expect(rendered).to have_text('Aucune règle')
    end
  end
end
