RSpec.describe Molecules::FormErrorSummaryComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(record: authorization_request)) }

  let(:authorization_request) do
    build(:authorization_request, :registre_wallet, organization: create(:organization, siret: '21920023500014'), **attributes).tap do |request|
      request.current_build_step = 'wallet_organization'
      request.validate
    end
  end
  let(:attributes) { { wallet_not_registered_elsewhere: true } }

  it 'counts the points to fix' do
    expect(rendered).to have_css('.fr-alert--error h3', text: '2 points à corriger avant de continuer')
  end

  it 'leaves no margin under the list, like the prototype' do
    expect(rendered).to have_css('.fr-alert--error ul.fr-mb-0')
  end

  it 'uses the wording of the prototype for the support channel' do
    expect(rendered).to have_link('Assistance aux usagers : indiquez au moins un moyen.', href: '#authorization_request_registre_wallet_wallet_support_url')
  end

  context 'without the declaration checked' do
    let(:attributes) { { wallet_privacy_policy_url: 'https://exemple.fr', wallet_support_email: 'contact@clamart.fr' } }

    it 'uses the wording of the prototype' do
      expect(rendered).to have_link('Cochez cette case pour continuer.')
    end
  end

  it 'links each point to its field' do
    expect(rendered).to have_link('Indiquez l’adresse de votre politique de confidentialité, par exemple https://www.exemple.fr/confidentialite', href: '#authorization_request_registre_wallet_wallet_privacy_policy_url')
  end

  context 'with a single error using a summary wording' do
    let(:attributes) { { wallet_not_registered_elsewhere: true, wallet_privacy_policy_url: 'http://exemple.fr', wallet_support_email: 'contact@clamart.fr' } }

    it 'uses the singular title and the summary wording' do
      expect(rendered).to have_css('h3', text: 'Un point à corriger avant de continuer')
      expect(rendered).to have_link('Politique de confidentialité : l’adresse doit commencer par https://')
    end
  end

  context 'without errors' do
    let(:attributes) { { wallet_not_registered_elsewhere: true, wallet_privacy_policy_url: 'https://exemple.fr', wallet_support_email: 'contact@clamart.fr' } }

    it { expect(rendered.to_html).to be_empty }
  end

  context 'with an error on a nested intended use' do
    before do
      authorization_request.errors.clear
      authorization_request.errors.add(:wallet_intended_uses_attributes_0_purpose, :wallet_intended_use_purpose_too_short, use_name: 'Vérifier la majorité', message: 'trop courte')
    end

    it 'names the use in the summary wording and links to its field' do
      expect(rendered).to have_link('Vérifier la majorité : la finalité est trop courte.', href: '#authorization_request_registre_wallet_wallet_intended_uses_attributes_0_purpose')
    end
  end

  context 'with an error carrying I18n lookup options' do
    before do
      authorization_request.errors.clear
      authorization_request.errors.add(:wallet_intended_uses_attributes_0_purpose, :wallet_intended_use_purpose_too_short, use_name: 'Vérifier la majorité', scope: 'unknown', default: 'ignored', message: 'trop courte')
    end

    it 'only passes the interpolated options to the summary wording' do
      expect(rendered).to have_link('Vérifier la majorité : la finalité est trop courte.')
    end
  end
end
