require 'rails_helper'

RSpec.describe DeliverHubEEFormulaireQFNotification do
  describe '#call' do
    subject(:interactor) do
      described_class.call(
        authorization_request:,
        authorization: current_authorization,
        authorization_request_notifier_params: { within_reopening: }
      )
    end

    let(:authorization_request) { create(:authorization_request, :formulaire_qf, :validated) }
    let(:current_authorization) { authorization_request.latest_authorization }
    let(:within_reopening) { false }

    context 'when the request is a formulaire QF validated for the first time' do
      it 'delivers the HubEE support email' do
        expect { interactor }.to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when the request is not a formulaire QF' do
      let(:authorization_request) { create(:authorization_request, :api_particulier_3d_ouest, :validated, modalities: %w[params]) }

      it 'does not deliver the HubEE support email' do
        expect { interactor }.not_to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when the feature flag is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:hubee_formulaire_qf_notification).and_return(false)
      end

      it 'does not deliver the HubEE support email' do
        expect { interactor }.not_to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
      end
    end

    context 'when it is a reopening' do
      let(:within_reopening) { true }
      let(:current_authorization) { create(:authorization, request: authorization_request, data: authorization_request.data) }

      context 'when the previous authorization was already a formulaire QF' do
        it 'does not deliver a second HubEE support email' do
          expect { interactor }.not_to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
        end
      end

      context 'when the reopening adds the formulaire QF modality' do
        let(:authorization_request) do
          create(:authorization_request, :api_particulier_3d_ouest, :validated, modalities: %w[params]).tap do |request|
            request.modalities = %w[params formulaire_qf]
            request.save!(validate: false)
          end
        end

        it 'delivers the HubEE support email' do
          expect { interactor }.to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
        end
      end

      context 'when there is no previous authorization' do
        let(:current_authorization) { authorization_request.latest_authorization }

        it 'does not deliver the HubEE support email' do
          expect { interactor }.not_to have_enqueued_mail(HubEEMailer, :formulaire_qf_validation)
        end
      end
    end
  end
end
