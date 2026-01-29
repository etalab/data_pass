require 'rails_helper'

RSpec.describe TabsHelper do
  before do
    helper.extend(Pundit::Authorization)
  end

  describe '#authorization_request_tabs' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
    let(:mock_policy) { instance_double(AuthorizationRequestPolicy) }
    let(:expected_tabs) { { authorization_request: '/path' } }

    it 'delegates to AuthorizationRequestTabsBuilder' do
      allow(helper).to receive(:policy).and_return(mock_policy)
      builder = instance_double(AuthorizationRequestTabsBuilder, build: expected_tabs)
      allow(AuthorizationRequestTabsBuilder).to receive(:new)
        .with(authorization_request, mock_policy)
        .and_return(builder)

      result = helper.authorization_request_tabs(authorization_request)

      expect(result).to eq(expected_tabs)
    end
  end

  describe '#authorization_tabs' do
    let(:authorization) { create(:authorization) }
    let(:mock_policy) { instance_double(AuthorizationPolicy) }
    let(:expected_tabs) { { authorization: '/path' } }

    it 'delegates to AuthorizationTabsBuilder' do
      allow(helper).to receive(:policy).and_return(mock_policy)
      builder = instance_double(AuthorizationTabsBuilder, build: expected_tabs)
      allow(AuthorizationTabsBuilder).to receive(:new)
        .with(authorization, mock_policy)
        .and_return(builder)

      result = helper.authorization_tabs(authorization)

      expect(result).to eq(expected_tabs)
    end
  end

  describe '#show_authorization_request_tabs?' do
    it 'returns false for draft requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :draft)

      expect(helper.show_authorization_request_tabs?(authorization_request)).to be false
    end

    it 'returns false for new records' do
      authorization_request = build(:authorization_request, :api_entreprise)

      expect(helper.show_authorization_request_tabs?(authorization_request)).to be false
    end

    it 'returns false for nil' do
      expect(helper.show_authorization_request_tabs?(nil)).to be false
    end

    it 'returns true for changes_requested requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :changes_requested)

      expect(helper.show_authorization_request_tabs?(authorization_request)).to be true
    end

    it 'returns true for submitted requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :submitted)

      expect(helper.show_authorization_request_tabs?(authorization_request)).to be true
    end

    it 'returns true for validated requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :validated)

      expect(helper.show_authorization_request_tabs?(authorization_request)).to be true
    end
  end

  describe '#show_authorization_tabs?' do
    it 'returns false for nil' do
      expect(helper.show_authorization_tabs?(nil)).to be false
    end

    it 'returns true for any authorization' do
      authorization = create(:authorization)

      expect(helper.show_authorization_tabs?(authorization)).to be true
    end
  end
end
