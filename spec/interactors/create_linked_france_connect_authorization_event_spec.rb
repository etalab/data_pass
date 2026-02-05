require 'rails_helper'

RSpec.describe CreateLinkedFranceConnectAuthorizationEvent do
  describe '#call' do
    subject(:interactor) { described_class.call(context) }

    let(:user) { create(:user, :instructor) }
    let(:authorization_request) { create(:authorization_request, :api_particulier) }
    let(:authorization) { create(:authorization, request: authorization_request) }

    context 'when linked_france_connect_authorization is present' do
      let(:linked_authorization) do
        create(:authorization,
          request: authorization_request,
          parent_authorization: authorization,
          authorization_request_class: 'AuthorizationRequest::FranceConnect')
      end

      let(:context) do
        Interactor::Context.new(
          user: user,
          authorization_request: authorization_request,
          linked_france_connect_authorization: linked_authorization
        )
      end

      it { is_expected.to be_success }

      it 'creates an auto_generate event' do
        expect { interactor }.to change(AuthorizationRequestEvent, :count).by(1)
      end

      it 'creates an event with correct name' do
        interactor

        event = AuthorizationRequestEvent.last
        expect(event.name).to eq('auto_generate')
      end

      it 'creates an event with correct entity' do
        interactor

        event = AuthorizationRequestEvent.last
        expect(event.entity).to eq(linked_authorization)
      end

      it 'creates an event with correct user' do
        interactor

        event = AuthorizationRequestEvent.last
        expect(event.user).to eq(user)
      end

      it 'creates an event with correct authorization_request' do
        interactor

        event = AuthorizationRequestEvent.last
        expect(event.authorization_request).to eq(authorization_request)
      end

      it 'stores the event in context' do
        expect(interactor.linked_france_connect_authorization_event).to be_a(AuthorizationRequestEvent)
      end
    end

    context 'when linked_france_connect_authorization is nil' do
      let(:context) do
        Interactor::Context.new(
          user: user,
          authorization_request: authorization_request,
          linked_france_connect_authorization: nil
        )
      end

      it { is_expected.to be_success }

      it 'does not create any event' do
        expect { interactor }.not_to change(AuthorizationRequestEvent, :count)
      end

      it 'does not set the event in context' do
        expect(interactor.linked_france_connect_authorization_event).to be_nil
      end
    end
  end
end
