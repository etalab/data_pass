require 'rails_helper'

RSpec.describe DeprecatePreviousAuthorizations do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:, authorization: current_authorization) }

    let!(:previous_authorization) { create(:authorization, request: authorization_request) }

    let(:authorization_request) { create(:authorization_request) }
    let(:current_authorization) { create(:authorization, request: authorization_request) }

    it 'deprecates the previous authorizations' do
      expect { interactor }.to change { previous_authorization.reload.state }.from('active').to('obsolete')
    end

    it 'exposes the deprecated authorizations' do
      expect(interactor.deprecated_authorizations).to contain_exactly(previous_authorization)
    end
  end
end
