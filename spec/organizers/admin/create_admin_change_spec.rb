RSpec.describe Admin::CreateAdminChange, type: :organizer do
  describe '.call' do
    let(:admin) { create(:user, :admin) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:public_reason) { 'Correction des données du responsable technique' }
    let(:private_reason) { 'Ticket support #SP-1234' }

    context 'with a block that modifies authorization_request data' do
      subject(:create_admin_change) do
        described_class.call(
          user: admin,
          authorization_request:,
          public_reason:,
          private_reason:,
        ) { |ar| ar.update!(data: ar.data.merge('intitule' => 'Nouveau titre')) }
      end

      it { is_expected.to be_success }

      it 'creates an AdminChange with computed diff' do
        expect { create_admin_change }.to change(AdminChange, :count).by(1)

        admin_change = AdminChange.last

        expect(admin_change.public_reason).to eq(public_reason)
        expect(admin_change.private_reason).to eq(private_reason)
        expect(admin_change.diff).to include('intitule')
        expect(admin_change.authorization_request).to eq(authorization_request)
      end

      it 'creates an AuthorizationRequestEvent' do
        expect { create_admin_change }.to change(AuthorizationRequestEvent, :count).by(1)

        event = AuthorizationRequestEvent.last

        expect(event.name).to eq('admin_change')
        expect(event.user).to eq(admin)
        expect(event.entity).to be_a(AdminChange)
        expect(event.authorization_request).to eq(authorization_request)
      end

      it 'applies the changes on the authorization_request' do
        create_admin_change

        expect(authorization_request.reload.data['intitule']).to eq('Nouveau titre')
      end
    end

    context 'with a block that modifies an authorization (habilitation)' do
      subject(:create_admin_change) do
        described_class.call(
          user: admin,
          authorization_request:,
          public_reason:,
        ) { |_ar| authorization.update!(data: authorization.data.merge('custom_field' => 'new_value')) }
      end

      let(:authorization) { create(:authorization, request: authorization_request) }

      it { is_expected.to be_success }

      it 'creates an AdminChange with empty diff' do
        create_admin_change

        expect(AdminChange.last.diff).to eq({})
      end

      it 'creates an AuthorizationRequestEvent' do
        expect { create_admin_change }.to change(AuthorizationRequestEvent, :count).by(1)
      end
    end

    context 'without a block' do
      subject(:create_admin_change) do
        described_class.call(
          user: admin,
          authorization_request:,
          public_reason:,
          private_reason:,
        )
      end

      it { is_expected.to be_success }

      it 'creates an AdminChange with empty diff' do
        create_admin_change

        expect(AdminChange.last.diff).to eq({})
        expect(AdminChange.last.public_reason).to eq(public_reason)
      end

      it 'creates an AuthorizationRequestEvent' do
        expect { create_admin_change }.to change(AuthorizationRequestEvent, :count).by(1)
      end
    end

    context 'without public_reason' do
      subject(:create_admin_change) do
        described_class.call(
          user: admin,
          authorization_request:,
          public_reason: nil,
        )
      end

      it { is_expected.to be_failure }

      it 'does not create an AdminChange' do
        expect { create_admin_change }.not_to change(AdminChange, :count)
      end

      it 'does not create an AuthorizationRequestEvent' do
        expect { create_admin_change }.not_to change(AuthorizationRequestEvent, :count)
      end
    end
  end
end
