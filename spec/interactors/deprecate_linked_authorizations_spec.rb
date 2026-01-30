require 'rails_helper'

RSpec.describe DeprecateLinkedAuthorizations do
  describe '#call' do
    subject(:interactor) { described_class.call(deprecated_authorizations:) }

    context 'when there are deprecated authorizations with linked FC authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }
      let!(:parent_authorization) { create(:authorization, request: authorization_request) }
      let!(:linked_fc_authorization) { create(:authorization, request: authorization_request, parent_authorization:) }
      let(:deprecated_authorizations) { [parent_authorization] }

      it 'deprecates the linked FC authorizations' do
        expect { interactor }.to change { linked_fc_authorization.reload.state }.from('active').to('obsolete')
      end
    end

    context 'when there are multiple deprecated authorizations with linked FC authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }
      let!(:first_parent_authorization) { create(:authorization, request: authorization_request) }
      let!(:second_parent_authorization) { create(:authorization, request: authorization_request) }
      let!(:first_linked_fc_authorization) { create(:authorization, request: authorization_request, parent_authorization: first_parent_authorization) }
      let!(:second_linked_fc_authorization) { create(:authorization, request: authorization_request, parent_authorization: second_parent_authorization) }
      let(:deprecated_authorizations) { [first_parent_authorization, second_parent_authorization] }

      it 'deprecates all linked FC authorizations' do
        interactor

        expect(first_linked_fc_authorization.reload.state).to eq('obsolete')
        expect(second_linked_fc_authorization.reload.state).to eq('obsolete')
      end
    end

    context 'when deprecated authorizations is nil' do
      let(:deprecated_authorizations) { nil }

      it 'does nothing' do
        expect { interactor }.not_to raise_error
      end
    end

    context 'when deprecated authorizations is empty' do
      let(:deprecated_authorizations) { [] }

      it 'does nothing' do
        expect { interactor }.not_to raise_error
      end
    end

    context 'when deprecated authorizations have no linked FC authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }
      let!(:parent_authorization) { create(:authorization, request: authorization_request) }
      let(:deprecated_authorizations) { [parent_authorization] }

      it 'does nothing' do
        expect { interactor }.not_to raise_error
      end
    end
  end
end
