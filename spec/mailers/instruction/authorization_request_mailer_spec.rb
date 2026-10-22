RSpec.describe Instruction::AuthorizationRequestMailer do
  describe '#submit' do
    subject(:mail) do
      described_class.with(
        authorization_request:,
        user: valid_instructor,
      ).submit
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
    let(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    it 'sends the email to the given user' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match("demande d'habilitation")
      expect(decoded_text_body(mail)).to match('a soumis')
      expect(decoded_text_body(mail)).to match(authorization_request.applicant.email)
    end

    it 'names the form without prefixing it with « l’API »' do
      expect(mail.body.encoded).to include("demande d'habilitation pour API Entreprise sur DataPass")
    end

    context 'when the authorization request has a modification request' do
      before do
        create(:instructor_modification_request, authorization_request: authorization_request)
      end

      it 'includes the changes_requested_submit message' do
        expect(decoded_text_body(mail)).to match('Cette demande fait suite à des modifications demandées.')
      end
    end

    context 'when the authorization request does not have a modification request' do
      it 'does not include the changes_requested_submit message' do
        expect(decoded_text_body(mail)).not_to match('Cette demande fait suite à des modifications demandées.')
      end
    end

    context 'with the unsubscribe footer' do
      it "mentionne le nom de l'API" do
        expect(decoded_text_body(mail)).to include(authorization_request.definition.name_with_stage)
      end

      it 'mentionne le texte de gestion des préférences' do
        expect(decoded_text_body(mail)).to include('ne plus recevoir ces notifications')
      end

      it 'inclut le lien de désinscription 1 clic' do
        expect(decoded_text_body(mail)).to include('/desabonnement-notifications?token=')
      end
    end

    it_behaves_like 'a mail whose html part mirrors its text part'
  end

  describe '#reopening_submit' do
    subject(:mail) do
      described_class.with(
        authorization_request:,
        user: valid_instructor,
      ).reopening_submit
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
    let(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    it 'sends the email to the given user' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match('demande de mise à jour')
      expect(decoded_text_body(mail)).to match('a soumis')
      expect(decoded_text_body(mail)).to match(authorization_request.applicant.email)
    end

    context 'with the unsubscribe footer' do
      it "mentionne le nom de l'API" do
        expect(decoded_text_body(mail)).to include(authorization_request.definition.name_with_stage)
      end

      it 'mentionne le texte de gestion des préférences' do
        expect(decoded_text_body(mail)).to include('ne plus recevoir ces notifications')
      end

      it 'inclut le lien de désinscription 1 clic' do
        expect(decoded_text_body(mail)).to include('/desabonnement-notifications?token=')
      end
    end

    it_behaves_like 'a mail whose html part mirrors its text part'
  end
end
