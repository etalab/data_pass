module HubEEHelpers
  shared_context 'with mocked hubee API client' do
    let(:hubee_api_client) { instance_double(HubEEAPIClient) }

    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive_messages(
        create_organization: organization_payload.with_indifferent_access,
        create_subscription: subscription_response.with_indifferent_access,
        get_organization: organization_payload.with_indifferent_access
      )
    end
  end

  shared_examples 'organization creation in hubee on approve' do
    context 'when organization exists on HubEE' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_return(organization_payload.with_indifferent_access)
      end

      it 'does not create a new organization on HubEE' do
        subject

        expect(hubee_api_client).not_to have_received(:create_organization)
      end
    end

    context 'when organization does not exists' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_raise(Faraday::ResourceNotFound)
      end

      it 'calls create_organization' do
        expect(hubee_api_client).to receive(:create_organization).with(organization_payload.deep_symbolize_keys)

        subject
      end
    end
  end
end
