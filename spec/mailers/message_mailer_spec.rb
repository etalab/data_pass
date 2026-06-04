RSpec.describe MessageMailer do
  describe '#to_applicant' do
    let(:mail) { described_class.with(message:).to_applicant }
    let(:message) { create(:message) }

    it 'sends the email to the applicant associated to authorization request message' do
      expect(mail.to).to eq([message.authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
      expect(mail.body.encoded).to match('demande d\'habilitation')
    end
  end

  describe '#reopening_to_applicant' do
    let(:mail) { described_class.with(message:).reopening_to_applicant }
    let(:message) { create(:message) }

    it 'sends the email to the applicant associated to authorization request message' do
      expect(mail.to).to eq([message.authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
      expect(mail.body.encoded).to match('demande de réouverture de l\'habilitation')
    end
  end

  describe '#to_instructors' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:message) { create(:message, authorization_request:) }
    let(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    let(:mail) { described_class.with(message:, user: valid_instructor).to_instructors }

    it 'sends the email to the given user' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
      expect(mail.body.encoded).to match('demande d\'habilitation')
    end

    context 'with the unsubscribe footer' do
      it 'inclut le lien vers la page de préférences' do
        expect(mail.body.encoded).to include('/compte#notifications-section')
      end

      it "mentionne le nom de l'API" do
        expect(mail.body.encoded).to include(authorization_request.definition.name_with_stage)
      end

      it 'mentionne le texte de gestion des préférences' do
        expect(mail.body.encoded).to include('ne plus recevoir ces notifications')
      end

      it 'inclut le lien de désinscription 1 clic' do
        expect(mail.body.encoded).to include('/desabonnement-notifications?token=')
      end
    end
  end

  describe '#reopening_to_instructors' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:message) { create(:message, authorization_request:) }
    let(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    let(:mail) { described_class.with(message:, user: valid_instructor).reopening_to_instructors }

    it 'sends the email to the given user' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
      expect(mail.body.encoded).to match('demande de réouverture de l\'habilitation')
    end

    context 'with the unsubscribe footer' do
      it 'inclut le lien vers la page de préférences' do
        expect(mail.body.encoded).to include('/compte#notifications-section')
      end

      it "mentionne le nom de l'API" do
        expect(mail.body.encoded).to include(authorization_request.definition.name_with_stage)
      end

      it 'mentionne le texte de gestion des préférences' do
        expect(mail.body.encoded).to include('ne plus recevoir ces notifications')
      end

      it 'inclut le lien de désinscription 1 clic' do
        expect(mail.body.encoded).to include('/desabonnement-notifications?token=')
      end
    end
  end
end
