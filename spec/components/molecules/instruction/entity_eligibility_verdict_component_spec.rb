require 'rails_helper'

RSpec.describe Molecules::Instruction::EntityEligibilityVerdictComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(verdict:)) }

  let(:verdict) { EntityEligibility::Verdict.new(status:) }

  context 'when the verdict is eligible' do
    let(:status) { :eligible }

    it 'renders a success badge labelled « Valide »' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--success', text: 'Valide')
    end
  end

  context 'when the verdict is likely_eligible' do
    let(:status) { :likely_eligible }

    it 'renders an info badge labelled « Valide (à confirmer) »' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--info', text: 'Valide (à confirmer)')
    end
  end

  context 'when the verdict is ineligible' do
    let(:status) { :ineligible }

    it 'renders an error badge labelled « Invalide »' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--error', text: 'Invalide')
    end
  end

  context 'when the verdict is unknown' do
    let(:status) { :unknown }

    it 'renders a neutral badge without a semantic modifier' do
      expect(rendered).to have_css('p.fr-badge', text: 'Éligibilité indéterminée')
      expect(rendered).to have_no_css('.fr-badge--success, .fr-badge--error, .fr-badge--info, .fr-badge--warning')
    end
  end
end
