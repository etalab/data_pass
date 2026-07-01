require 'rails_helper'

RSpec.describe Molecules::Instruction::EntityEligibilityBannerComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(status:)) }

  context 'when the request was auto-validated' do
    let(:status) { :validated }

    it 'renders a success notice explaining the automatic validation' do
      expect(rendered).to have_css('div.fr-notice.eligibility-notice--success.fr-notice--no-icon')
      expect(rendered).to have_css('.fr-notice__title', text: 'Demande validée automatiquement')
      expect(rendered).to have_text('éligible')
    end
  end

  context 'when the request was auto-refused' do
    let(:status) { :refused }

    it 'renders an alert notice explaining the automatic refusal' do
      expect(rendered).to have_css('div.fr-notice.fr-notice--alert.fr-notice--no-icon')
      expect(rendered).to have_css('.fr-notice__title', text: 'Demande refusée automatiquement')
      expect(rendered).to have_text('ne la rend pas éligible')
    end
  end

  context 'when the verdict is likely eligible' do
    let(:status) { :likely_eligible }

    it 'renders an info notice asking for a manual review' do
      expect(rendered).to have_css('div.fr-notice.fr-notice--info.fr-notice--no-icon')
      expect(rendered).to have_css('.fr-notice__title', text: 'L’organisation semble éligible')
      expect(rendered).to have_text('À confirmer manuellement')
    end
  end

  context 'when the verdict is likely ineligible' do
    let(:status) { :likely_ineligible }

    it 'renders a warning notice asking for a manual review' do
      expect(rendered).to have_css('div.fr-notice.fr-notice--warning.fr-notice--no-icon')
      expect(rendered).to have_css('.fr-notice__title', text: 'L’organisation semble inéligible')
      expect(rendered).to have_text('À confirmer manuellement')
    end
  end
end
