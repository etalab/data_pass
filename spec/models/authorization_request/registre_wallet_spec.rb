RSpec.describe AuthorizationRequest::RegistreWallet do
  subject(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, **attributes) }

  let(:siret) { '32816124500027' }
  let(:organization) { create(:organization, siret:) }

  let(:complete_attributes) do
    {
      wallet_privacy_policy_url: 'https://velocite.example/confidentialite',
      wallet_support_email: 'contact@velocite.example',
      wallet_not_registered_elsewhere: true,
    }
  end
  let(:attributes) { complete_attributes }

  def error_messages_for(attribute)
    authorization_request.errors.messages_for(attribute)
  end

  describe 'step « L’organisation » validation' do
    before do
      authorization_request.current_build_step = 'wallet_organization'
      authorization_request.validate
    end

    context 'with every published information filled' do
      it { is_expected.to be_valid }
    end

    context 'without privacy policy nor support channel' do
      let(:attributes) { complete_attributes.merge(wallet_privacy_policy_url: nil, wallet_support_email: nil) }

      it 'lists the two points to fix' do
        expect(authorization_request.errors.attribute_names).to contain_exactly(:wallet_privacy_policy_url, :wallet_support_url)
      end

      it 'asks for at least one support channel, on the first one' do
        expect(error_messages_for(:wallet_support_url)).to eq(['Indiquez au moins un moyen d’assistance : un site, une adresse électronique ou un téléphone. L’usager s’en sert aussi pour demander la suppression de ses données.'])
      end
    end

    context 'with an address that does not start with https://' do
      let(:attributes) { complete_attributes.merge(wallet_website_url: 'http://velocite.example') }

      it 'shows the https message without the attribute name' do
        expect(authorization_request.errors.full_messages_for(:wallet_website_url)).to eq(['Indiquez une adresse qui commence par https://, par exemple https://www.exemple.fr'])
      end
    end

    context 'with an address without a domain extension' do
      let(:attributes) { complete_attributes.merge(wallet_support_url: 'https://velocite') }

      it { expect(error_messages_for(:wallet_support_url)).to be_present }
    end

    context 'with an invalid support email' do
      let(:attributes) { complete_attributes.merge(wallet_support_email: 'contact@velocite.e') }

      it { expect(error_messages_for(:wallet_support_email)).to eq(['Indiquez une adresse électronique valide, par exemple nom@domaine.fr']) }
    end

    context 'without the declaration checked' do
      let(:attributes) { complete_attributes.merge(wallet_not_registered_elsewhere: false) }

      it { expect(error_messages_for(:wallet_not_registered_elsewhere)).to eq(['Cochez cette case pour continuer.']) }
    end

    {
      '04 72 00 00 00' => '04 72 00 00 00',
      '04.72.00.00.00' => '04.72.00.00.00',
      '(04) 72 00 00 00' => '04 72 00 00 00',
      '+33 (0)4 72 00 00 00' => '+33 4 72 00 00 00',
    }.each do |typed, saved|
      context "with the support phone typed as « #{typed} »" do
        let(:attributes) { complete_attributes.merge(wallet_support_phone: typed) }

        it 'accepts it and keeps it normalized' do
          expect([authorization_request.valid?, authorization_request.wallet_support_phone]).to eq([true, saved])
        end
      end
    end

    ['+41 22 000 00 00', '12 34'].each do |typed|
      context "with the support phone typed as « #{typed} »" do
        let(:attributes) { complete_attributes.merge(wallet_support_phone: typed) }

        it { expect(error_messages_for(:wallet_support_phone)).to eq(['Indiquez un numéro de téléphone valide, par exemple 04 72 00 00 00']) }
      end
    end
  end

  describe 'saving a draft within the wizard' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:, wallet_support_email: 'contact@velocite.example') }

    context 'with empty fields' do
      it 'keeps the draft valid' do
        authorization_request.wallet_privacy_policy_url = nil

        expect(authorization_request.save(context: :save_within_wizard)).to be true
      end
    end

    context 'with a badly formatted value' do
      before do
        authorization_request.assign_attributes(wallet_website_url: 'http://velocite.example', wallet_support_url: 'https://aide.velocite.example')
        authorization_request.save(context: :save_within_wizard)
      end

      it 'saves the well formatted values and keeps the previous value of the badly formatted one' do
        authorization_request.reload

        expect([authorization_request.wallet_support_url, authorization_request.wallet_website_url]).to eq(['https://aide.velocite.example', nil])
      end

      it 'remembers the value set aside' do
        expect(authorization_request.draft_set_aside_values).to eq(wallet_website_url: 'http://velocite.example')
      end

      it 'gives the value back with its message, for display' do
        authorization_request.reveal_draft_set_aside_values!

        expect([authorization_request.wallet_website_url, authorization_request.errors.details[:wallet_website_url]]).to eq(['http://velocite.example', [{ error: :wallet_https_format }]])
      end
    end
  end

  describe 'formats outside the current step' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:) }

    it 'are checked as soon as the value is filled, whatever the step' do
      authorization_request.wallet_website_url = 'http://velocite.example'

      expect(authorization_request.valid?).to be false
    end
  end

  describe 'identity copied from the INSEE data when the request is built' do
    context 'with a company (SAS)' do
      it 'is not a public sector body' do
        expect([authorization_request.wallet_public_sector?, authorization_request.applicant_capacity]).to eq([false, :unknown])
      end

      it { expect(authorization_request.wallet_identity_source).to eq(:sirene) }
    end

    context 'with a municipality' do
      let(:siret) { '21920023500014' }

      it 'is a public sector body, with a connected agent' do
        expect([authorization_request.wallet_public_sector?, authorization_request.applicant_capacity]).to eq([true, :public_agent])
      end
    end

    context 'with an industrial and commercial public body (category 4…)' do
      before do
        payload = organization.insee_payload.deep_dup
        payload['etablissement']['uniteLegale']['categorieJuridiqueUniteLegale'] = '4110'
        organization.update!(insee_payload: payload)
      end

      it { expect(authorization_request.wallet_public_sector?).to be true }
    end

    context 'when the INSEE data of the organization changes afterwards' do
      before do
        authorization_request.save!
        organization.update!(insee_payload: organization.insee_payload.deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => 'NOUVEAU NOM' } }))
      end

      it 'keeps the copy of the request' do
        expect(authorization_request.reload.identity_legal_name).not_to eq('NOUVEAU NOM')
      end
    end

    it 'cannot be changed by the applicant' do
      expect(described_class.extra_attributes).not_to include(:identity_legal_name, :identity_vat_number, :identity_source)
    end
  end

  describe 'step validation according to the identity source' do
    before do
      authorization_request.current_build_step = 'wallet_organization'
      authorization_request.validate
    end

    context 'when the INSEE data is still loading' do
      let(:siret) { '21920023500022' }
      let(:organization) { create(:organization, siret:).tap { |org| org.update!(insee_payload: nil) } }

      it { expect(authorization_request.wallet_identity_source).to eq(:sirene_pending) }

      it 'lets the applicant continue, without asking to type the identity' do
        expect(authorization_request.errors.attribute_names).not_to include(:identity_source, :identity_address)
      end

      it 'asks to update the identity before submitting' do
        authorization_request.valid?(:submit)

        expect(error_messages_for(:identity_source)).to eq(['Les informations de votre organisation sont encore en cours de chargement. Mettez-les à jour à l’étape « L’organisation » avant de soumettre votre demande.'])
      end
    end

    context 'when Sirene did not answer (no INSEE data)' do
      let(:siret) { '21920023500022' }
      let(:organization) { create(:organization, siret:).tap { |org| org.update!(insee_payload: nil, insee_consecutive_failures: 1) } }

      it { expect(authorization_request.wallet_identity_source).to eq(:sirene_unavailable) }

      it 'lets the applicant continue, without asking to type the identity' do
        expect(authorization_request.errors.attribute_names).not_to include(:identity_source, :identity_address)
      end
    end

    context 'when the establishment is not diffusible, Sirene giving its address (fixture : forme supposée de la réponse 3.11 privée, non vérifiée sur un vrai SIRET)' do
      let(:siret) { '12345678900023' }

      it { expect(authorization_request.wallet_identity_source).to eq(:non_diffusible) }

      it 'lets the applicant continue, without asking to type the address' do
        expect(authorization_request.errors).to be_empty
      end

      it 'keeps the address, but never as a publishable one' do
        expect(authorization_request.values_at(:identity_address, :wallet_publishable_address)).to eq(['12 rue des Cyclistes, 69003 Lyon 3e Arrondissement', nil])
      end

      it 'can be submitted as far as the address is concerned' do
        authorization_request.valid?(:submit)

        expect(authorization_request.errors.attribute_names).not_to include(:identity_address)
      end
    end

    context 'when the establishment is not diffusible and Sirene withholds its address as « [ND] »' do
      let(:siret) { '12345678900015' }

      it 'lets the applicant continue, without asking to type the address' do
        expect(authorization_request.errors).to be_empty
      end

      it 'refuses the submission, telling to update the address with the INSEE then retry' do
        authorization_request.valid?(:submit)

        expect(error_messages_for(:identity_address)).to eq(['Le répertoire Sirene ne donne pas l’adresse de votre établissement. Mettez-la à jour auprès de l’INSEE, puis relancez la récupération depuis l’étape « L’organisation » avant de soumettre votre demande.'])
      end
    end

    context 'when the establishment is diffusible' do
      let(:siret) { '21920023500014' }

      it 'publishes the address read in Sirene' do
        expect(authorization_request.wallet_publishable_address).to eq('1 place Maurice Gunsbourg, 92140 Clamart')
      end
    end
  end

  describe 'saving a draft while Sirene does not answer' do
    let(:organization) { create(:organization, siret: '21920023500022').tap { |org| org.update!(insee_payload: nil) } }
    let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:) }

    it 'keeps the draft valid' do
      expect(authorization_request.save(context: :save_within_wizard)).to be true
    end
  end

  describe 'step « Le service »' do
    subject(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, applicant:, **attributes) }

    let(:organization) { create(:organization, siret: '21920023500014') }
    let(:applicant) { create(:user).tap { |user| user.add_to_organization(organization, current: true) } }
    let(:service_attributes) do
      {
        wallet_privacy_policy_url: 'https://www.clamart.fr/confidentialite',
        wallet_support_email: 'contact@clamart.fr',
        wallet_not_registered_elsewhere: true,
        wallet_service_name: 'Vélocité Libre-service',
        wallet_service_identifier: 'libre-service',
        wallet_service_description: 'Location de vélos en libre-service dans la métropole de Lyon.',
      }
    end
    let(:attributes) { service_attributes }

    def validate_step
      authorization_request.current_build_step = 'wallet_service'
      authorization_request.validate
    end

    def error_messages_for(attribute)
      authorization_request.errors.messages_for(attribute)
    end

    describe 'identifier proposal' do
      {
        'Vélo Été' => 'velo-ete',
        'Œuvre d’art  & Cie !' => 'oeuvre-d-art-cie',
        '  Libre-service Lyon ' => 'libre-service-lyon',
      }.each do |name, identifier|
        it "proposes « #{identifier} » for « #{name} »" do
          expect(AuthorizationExtensions::WalletService.propose_identifier(name)).to eq(identifier)
        end
      end

      context 'when the identifier is empty' do
        let(:attributes) { service_attributes.merge(wallet_service_name: 'Vélo Été', wallet_service_identifier: '') }

        it 'fills it from the service name when the draft is saved' do
          authorization_request.save!(context: :save_within_wizard)

          expect(authorization_request.reload.wallet_service_identifier).to eq('velo-ete')
        end
      end

      context 'when the applicant typed an identifier' do
        let(:attributes) { service_attributes.merge(wallet_service_name: 'Vélo Été Lyon', wallet_service_identifier: 'mon-service') }

        it 'keeps it' do
          authorization_request.save!(context: :save_within_wizard)

          expect(authorization_request.reload.wallet_service_identifier).to eq('mon-service')
        end
      end
    end

    describe 'validation of the step' do
      before { validate_step }

      context 'with the three fields filled' do
        it { is_expected.to be_valid }

        it 'declares the service as a service provider' do
          expect(authorization_request.wallet_entitlement).to eq('Service_Provider')
        end
      end

      context 'with nothing filled' do
        let(:attributes) { service_attributes.merge(wallet_service_name: nil, wallet_service_identifier: nil, wallet_service_description: nil) }

        it 'lists the three fields' do
          expect(authorization_request.errors.attribute_names).to contain_exactly(:wallet_service_name, :wallet_service_identifier, :wallet_service_description)
        end
      end

      context 'with a name of 51 characters' do
        let(:attributes) { service_attributes.merge(wallet_service_name: 'V' * 51) }

        it 'asks to shorten it, with its length' do
          expect(error_messages_for(:wallet_service_name)).to eq(['Le nom du service compte 51 caractères. Raccourcissez-le à 50 caractères au plus : il s’affiche dans le wallet.'])
        end
      end

      context 'with a name of 50 characters' do
        let(:attributes) { service_attributes.merge(wallet_service_name: 'V' * 50) }

        it { is_expected.to be_valid }
      end

      ['Libre-Service', 'libre_service', '-libre', 'libre-', 'libre--service', 'libre service', 'vélo'].each do |identifier|
        context "with the identifier « #{identifier} »" do
          let(:attributes) { service_attributes.merge(wallet_service_identifier: identifier) }

          it 'refuses its format' do
            expect(error_messages_for(:wallet_service_identifier)).to eq(['L’identifiant ne peut contenir que des lettres minuscules sans accent, des chiffres et des tirets, par exemple libre-service-lyon.'])
          end
        end
      end

      ['test', '.............................', '   ...   !!!   ???   '].each do |description|
        context "with the description « #{description} »" do
          let(:attributes) { service_attributes.merge(wallet_service_description: description) }

          it 'asks for a real description' do
            expect(authorization_request.errors.attribute_names).to include(:wallet_service_description)
          end
        end
      end
    end

    describe 'saving a draft with a badly formatted name' do
      let(:attributes) { service_attributes.merge(wallet_service_name: 'V' * 51) }

      it 'saves the rest of the draft and shows the name again with its error' do
        expect(authorization_request.save(context: :save_within_wizard)).to be true

        authorization_request.reveal_draft_set_aside_values!

        expect(authorization_request.reload.wallet_service_identifier).to eq('libre-service')
        expect(authorization_request.data['wallet_service_name']).to be_nil
      end
    end

    describe 'identifier already used in the organization' do
      def create_other_request(*traits, organization: self.organization, identifier: 'libre-service')
        other_applicant = create(:user).tap { |user| user.add_to_organization(organization, current: true) }
        create(:authorization_request, :registre_wallet, *traits, organization:, applicant: other_applicant, wallet_service_identifier: identifier)
      end

      let(:taken_message) { 'Un autre service de votre organisation utilise déjà cet identifiant. Choisissez-en un autre.' }

      %i[submitted changes_requested validated].each do |state|
        context "when another request of the organization is #{state} with it" do
          before do
            create_other_request(state)
            validate_step
          end

          it 'refuses the identifier' do
            expect(error_messages_for(:wallet_service_identifier)).to eq([taken_message])
          end
        end
      end

      %i[draft refused archived].each do |state|
        context "when another request of the organization is #{state} with it" do
          before do
            create_other_request(state)
            validate_step
          end

          it { is_expected.to be_valid }
        end
      end

      context 'when another request with another identifier is submitted' do
        before do
          create_other_request(:submitted, identifier: 'autre-service')
          validate_step
        end

        it { is_expected.to be_valid }
      end

      context 'when another establishment of the same SIREN is submitted with it' do
        before do
          create_other_request(:submitted, organization: create(:organization, siret: '21920023500022'))
          validate_step
        end

        it 'refuses the identifier' do
          expect(error_messages_for(:wallet_service_identifier)).to eq([taken_message])
        end
      end

      context 'when an organization with another SIREN uses it' do
        before do
          create_other_request(:submitted, organization: create(:organization, siret: '32816124500027'))
          validate_step
        end

        it { is_expected.to be_valid }
      end

      context 'when the request itself is submitted' do
        subject(:authorization_request) { create(:authorization_request, :registre_wallet, :submitted, organization:, applicant:, wallet_service_identifier: 'libre-service') }

        it 'does not compare it with itself' do
          expect(authorization_request.reload).to be_valid
        end
      end

      context 'when a draft only saves' do
        before { create_other_request(:submitted) }

        it 'does not check the identifier yet' do
          authorization_request.save(context: :save_within_wizard)

          expect(authorization_request.errors.full_messages).to be_empty
        end
      end
    end
  end
end
