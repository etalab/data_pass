RSpec.describe RegisterOrganizationWithContactsOnCRMJob do
  subject { job_instance.perform_now }

  let(:job_instance) { described_class.new(authorization_request_id) }

  let(:hubspot_api) { instance_double(HubspotAPI) }
  let(:entity) { OpenStruct.new(id: 42, properties: {}) }

  context 'when authorization_request is not found' do
    let(:authorization_request_id) { -1 }

    it 'does not raises an error' do
      expect { subject }.not_to raise_error
    end
  end

  context 'when authorization_request is found' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }
    let(:authorization_request_id) { authorization_request.id }

    before do
      allow(HubspotAPI).to receive(:new).and_return(hubspot_api)

      allow(hubspot_api).to receive_messages(add_contact_to_company: true, create_company: entity, create_contact: entity)

      %i[
        update_company
        update_contact
      ].each do |method|
        allow(hubspot_api).to receive(method).and_return(true)
      end
    end

    context 'when there is no company nor contact on Hubspot' do
      before do
        %i[
          find_company_by_siret
          find_contact_by_email
        ].each do |method|
          allow(hubspot_api).to receive(method).and_return(nil)
        end
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when there is a company and at least one contact on Hubspot' do
      before do
        %i[
          find_company_by_siret
          find_contact_by_email
        ].each do |method|
          allow(hubspot_api).to receive(method).and_return(entity)
        end
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end

    describe 'non-regression test: when one contact already exists with one type' do
      before do
        allow(hubspot_api).to receive(:find_company_by_siret).and_return(entity)
        allow(hubspot_api).to receive(:find_contact_by_email).and_return(
          OpenStruct.new(id: 41, properties: { 'type_de_contact' => 'Responsable de traitement' }),
          entity,
        )
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
