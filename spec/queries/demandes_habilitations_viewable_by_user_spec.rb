RSpec.describe DemandesHabilitationsViewableByUser do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, current_organization: organization) }

  describe '#count with Authorization model' do
    subject(:count) { described_class.new(user, scoped_relation, Authorization).count }

    let(:scoped_relation) do
      Authorization
        .joins(:request)
        .where(authorization_requests: { organization: organization })
    end

    context 'when there are no authorizations' do
      it 'returns 0' do
        expect(count).to eq(0)
      end
    end

    context 'when there are authorizations in the scoped relation' do
      let!(:authorization_request) { create(:authorization_request, organization: organization, applicant: user, state: :validated) }
      let!(:authorization) { create(:authorization, request: authorization_request, state: :active) }

      it 'returns the count of authorizations' do
        expect(count).to eq(1)
      end
    end

    context 'when there are mentions of the user' do
      let(:other_organization) { create(:organization) }
      let!(:other_request) { create(:authorization_request, organization: other_organization, state: :validated, data: { 'responsable_technique_email' => user.email }) }
      let!(:mentioned_authorization) { create(:authorization, request: other_request, state: :active) }

      it 'includes authorizations where user is mentioned' do
        expect(count).to eq(1)
      end
    end

    context 'when there are both scoped authorizations and mentions' do
      let!(:authorization_request) { create(:authorization_request, organization: organization, applicant: user, state: :validated) }
      let!(:authorization) { create(:authorization, request: authorization_request, state: :active) }

      let(:other_organization) { create(:organization) }
      let!(:other_request) { create(:authorization_request, organization: other_organization, state: :validated, data: { 'responsable_technique_email' => user.email }) }
      let!(:mentioned_authorization) { create(:authorization, request: other_request, state: :active) }

      it 'returns the combined count without duplicates' do
        expect(count).to eq(2)
      end
    end
  end

  describe '#count with AuthorizationRequest model' do
    subject(:count) { described_class.new(user, scoped_relation, AuthorizationRequest).count }

    let(:scoped_relation) { AuthorizationRequest.where(organization: organization) }

    context 'when there are no authorization requests' do
      it 'returns 0' do
        expect(count).to eq(0)
      end
    end

    context 'when there are authorization requests in the scoped relation' do
      let!(:authorization_request) { create(:authorization_request, :api_entreprise, organization: organization, applicant: user, state: :draft) }

      it 'returns the count of authorization requests' do
        expect(count).to eq(1)
      end
    end

    context 'when there are mentions of the user' do
      let(:other_organization) { create(:organization) }
      let!(:mentioned_request) { create(:authorization_request, :api_entreprise, organization: other_organization, state: :draft, data: { 'responsable_technique_email' => user.email }) }

      it 'includes authorization requests where user is mentioned' do
        expect(count).to eq(1)
      end
    end

    context 'when there are both scoped authorization requests and mentions' do
      let!(:authorization_request) { create(:authorization_request, :api_entreprise, organization: organization, applicant: user, state: :draft) }

      let(:other_organization) { create(:organization) }
      let!(:mentioned_request) { create(:authorization_request, :api_entreprise, organization: other_organization, state: :draft, data: { 'responsable_technique_email' => user.email }) }

      it 'returns the combined count without duplicates' do
        expect(count).to eq(2)
      end
    end
  end
end
