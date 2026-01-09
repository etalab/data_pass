require 'rails_helper'

RSpec.describe TabsHelper do
  describe '#applicant_tabs_for' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    it 'always includes authorization_request tab' do
      tabs = helper.applicant_tabs_for(authorization_request)

      expect(tabs).to have_key(:authorization_request)
      expect(tabs[:authorization_request]).to eq(
        summary_authorization_request_form_path(
          form_uid: authorization_request.form_uid,
          id: authorization_request.id
        )
      )
    end

    it 'always includes authorization_request_events tab' do
      tabs = helper.applicant_tabs_for(authorization_request)

      expect(tabs).to have_key(:authorization_request_events)
      expect(tabs[:authorization_request_events]).to eq(authorization_request_events_path(authorization_request))
    end

    context 'when france_connect request with linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

      before do
        linked_auth = create(:authorization)
        linked_auth.data['france_connect_authorization_id'] = authorization_request.latest_authorization.id
        linked_auth.save!
      end

      it 'includes france_connected_authorizations tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).to have_key(:france_connected_authorizations)
        expect(tabs[:france_connected_authorizations]).to eq(
          authorization_request_france_connected_authorizations_path(authorization_request)
        )
      end
    end

    context 'when not a france_connect request' do
      it 'does not include france_connected_authorizations tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when messaging feature is enabled' do
      before do
        allow(authorization_request.definition).to receive(:feature?).with(:messaging).and_return(true)
      end

      it 'includes messages tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).to have_key(:messages)
        expect(tabs[:messages]).to eq(authorization_request_messages_path(authorization_request))
      end
    end

    context 'when messaging feature is disabled' do
      before do
        allow(authorization_request.definition).to receive(:feature?).with(:messaging).and_return(false)
      end

      it 'does not include messages tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).not_to have_key(:messages)
      end
    end

    context 'when authorizations exist' do
      before do
        create(:authorization, request: authorization_request)
      end

      it 'includes authorizations tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).to have_key(:authorizations)
        expect(tabs[:authorizations]).to eq(authorization_request_authorizations_path(authorization_request))
      end
    end

    context 'when no authorizations exist' do
      it 'does not include authorizations tab' do
        tabs = helper.applicant_tabs_for(authorization_request)

        expect(tabs).not_to have_key(:authorizations)
      end
    end
  end

  describe '#show_tabs_for_authorization_request?' do
    it 'returns false for nil' do
      expect(helper.show_tabs_for_authorization_request?(nil)).to be false
    end

    it 'returns false for new records' do
      authorization_request = build(:authorization_request, :api_entreprise)

      expect(helper.show_tabs_for_authorization_request?(authorization_request)).to be false
    end

    it 'returns false for draft requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :draft)

      expect(helper.show_tabs_for_authorization_request?(authorization_request)).to be false
    end

    it 'returns true for submitted requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :submitted)

      expect(helper.show_tabs_for_authorization_request?(authorization_request)).to be true
    end

    it 'returns true for validated requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :validated)

      expect(helper.show_tabs_for_authorization_request?(authorization_request)).to be true
    end

    it 'returns true for changes_requested requests' do
      authorization_request = create(:authorization_request, :api_entreprise, :changes_requested)

      expect(helper.show_tabs_for_authorization_request?(authorization_request)).to be true
    end
  end

  describe '#authorization_tabs_for' do
    let(:authorization) { create(:authorization) }

    it 'always includes authorization tab' do
      tabs = helper.authorization_tabs_for(authorization)

      expect(tabs).to have_key(:authorization)
      expect(tabs[:authorization]).to eq(authorization_path(authorization))
    end

    it 'always includes authorization_request_events tab' do
      tabs = helper.authorization_tabs_for(authorization)

      expect(tabs).to have_key(:authorization_request_events)
      expect(tabs[:authorization_request_events]).to eq(authorization_events_path(authorization))
    end

    context 'when france_connect authorization with linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      before do
        linked_auth = create(:authorization)
        linked_auth.data['france_connect_authorization_id'] = authorization.id
        linked_auth.save!
      end

      it 'includes france_connected_authorizations tab' do
        tabs = helper.authorization_tabs_for(authorization)

        expect(tabs).to have_key(:france_connected_authorizations)
        expect(tabs[:france_connected_authorizations]).to eq(
          authorization_france_connected_authorizations_path(authorization)
        )
      end
    end

    context 'when not a france_connect authorization' do
      it 'does not include france_connected_authorizations tab' do
        tabs = helper.authorization_tabs_for(authorization)

        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when messaging feature is enabled' do
      before do
        allow(authorization.request.definition).to receive(:feature?).with(:messaging).and_return(true)
      end

      it 'includes messages tab' do
        tabs = helper.authorization_tabs_for(authorization)

        expect(tabs).to have_key(:messages)
        expect(tabs[:messages]).to eq(authorization_messages_path(authorization))
      end
    end

    context 'when messaging feature is disabled' do
      before do
        allow(authorization.request.definition).to receive(:feature?).with(:messaging).and_return(false)
      end

      it 'does not include messages tab' do
        tabs = helper.authorization_tabs_for(authorization)

        expect(tabs).not_to have_key(:messages)
      end
    end
  end

  describe '#show_tabs_for_authorization?' do
    it 'returns false for nil' do
      expect(helper.show_tabs_for_authorization?(nil)).to be false
    end

    it 'returns true for any authorization' do
      authorization = create(:authorization)

      expect(helper.show_tabs_for_authorization?(authorization)).to be true
    end
  end
end
