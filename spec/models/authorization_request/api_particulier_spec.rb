RSpec.describe AuthorizationRequest::APIParticulier do
  describe 'modalities attribute' do
    subject { authorization_request.modalities }

    let(:authorization_request) { build(:authorization_request, :api_particulier) }

    it { is_expected.to be_a(Array) }

    it 'has a default value' do
      expect(subject).to eq(%w[params])
    end

    context 'with values' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, modalities: %w[params formulaire_qf]) }

      it { is_expected.to eq(%w[formulaire_qf params]) }
    end
  end

  describe 'modalities validation' do
    subject { build(:authorization_request, :api_particulier, modalities:) }

    context 'with valid values' do
      let(:modalities) { %w[formulaire_qf params] }

      it { is_expected.to be_valid }
    end

    context 'with invalid values' do
      let(:modalities) { %w[invalid] }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#skip_france_connect_authorization?' do
    subject { authorization_request.skip_france_connect_authorization? }

    context 'when service provider is fc_certified and feature flag is enabled' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(true)
      end

      let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik) }

      it { is_expected.to be true }
    end

    context 'when service provider is fc_certified but feature flag is disabled' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(false)
      end

      let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik) }

      it { is_expected.to be false }
    end

    context 'when service provider is not fc_certified' do
      let(:authorization_request) { build(:authorization_request, :api_particulier_arpege_concerto) }

      it { is_expected.to be false }
    end
  end

  describe '#requires_france_connect_authorization?' do
    subject { authorization_request.requires_france_connect_authorization? }

    context 'when skip_france_connect_authorization? is true' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(true)
      end

      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, modalities: ['france_connect'])
      end

      it { is_expected.to be false }
    end

    context 'when skip_france_connect_authorization? is false and france_connect modality selected' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(false)
        allow(authorization_request).to receive(:need_complete_validation?).with(:modalities).and_return(true)
      end

      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, modalities: ['france_connect'])
      end

      it { is_expected.to be false }
    end

    context 'when using existing FC authorization on certified form' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(true)
        allow(authorization_request).to receive(:need_complete_validation?).with(:modalities).and_return(true)
      end

      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik,
          modalities: ['france_connect'],
          fc_authorization_mode: 'use_existing')
      end

      it { is_expected.to be true }
    end
  end

  describe 'contact_technique_phone_number mobile validation' do
    context 'when service provider is FC certified' do
      let(:authorization_request) do
        build(
          :authorization_request,
          :api_particulier_entrouvert_publik,
          modalities:,
          contact_technique_phone_number: phone_number
        )
      end

      before do
        allow(authorization_request).to receive(:need_complete_validation?) do |key|
          key == :contacts
        end
      end

      context 'with france_connect modality' do
        let(:modalities) { ['france_connect'] }

        context 'with valid mobile phone number' do
          let(:phone_number) { '06 12 34 56 78' }

          it 'does not add mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end

        context 'with valid mobile phone number (alternative format)' do
          let(:phone_number) { '+33 6 12 34 56 78' }

          it 'does not add mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end

        context 'with landline phone number' do
          let(:phone_number) { '01 23 45 67 89' }

          it 'adds mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end
      end

      context 'without france_connect modality' do
        let(:modalities) { ['params'] }

        context 'with landline phone number' do
          let(:phone_number) { '01 23 45 67 89' }

          it 'does not add mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end
      end
    end

    context 'when service provider is NOT FC certified' do
      let(:authorization_request) do
        build(
          :authorization_request,
          :api_particulier_airweb,
          modalities:,
          contact_technique_phone_number: phone_number
        )
      end

      before do
        allow(authorization_request).to receive(:need_complete_validation?) do |key|
          key == :contacts
        end
      end

      context 'with france_connect modality' do
        let(:modalities) { ['france_connect'] }

        context 'with landline phone number' do
          let(:phone_number) { '01 23 45 67 89' }

          it 'does not add mobile validation error (mobile validation not applied)' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end

        context 'with mobile phone number' do
          let(:phone_number) { '06 12 34 56 78' }

          it 'does not add mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end
      end

      context 'without france_connect modality' do
        let(:modalities) { ['params'] }

        context 'with landline phone number' do
          let(:phone_number) { '01 23 45 67 89' }

          it 'does not add mobile validation error' do
            authorization_request.valid?
            expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
              I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
            )
          end
        end
      end
    end

    context 'when form has no service provider' do
      let(:authorization_request) do
        build(
          :authorization_request,
          :api_particulier,
          modalities: ['france_connect'],
          contact_technique_phone_number: phone_number
        )
      end

      before do
        allow(authorization_request).to receive(:need_complete_validation?) do |key|
          key == :contacts
        end
      end

      context 'with landline phone number' do
        let(:phone_number) { '01 23 45 67 89' }

        it 'does not add mobile validation error (mobile validation not applied)' do
          authorization_request.valid?
          expect(authorization_request.errors[:contact_technique_phone_number]).not_to include(
            I18n.t('activemodel.errors.messages.invalid_french_phone_mobile_format')
          )
        end
      end
    end
  end
end
