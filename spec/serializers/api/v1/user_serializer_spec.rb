RSpec.describe API::V1::UserSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { described_class.new(user).serializable_hash }

    let(:user) { create(:user, external_id: 'pro-connect-sub', job_title: 'Responsable informatique') }

    it 'includes the identity federator uid and the job title, like webhooks' do
      expect(serializable_hash).to include(
        id: user.id,
        uid: 'pro-connect-sub',
        email: user.email,
        job_title: 'Responsable informatique'
      )
    end

    context 'when the user never signed in through the identity federator' do
      let(:user) { create(:user, external_id: nil) }

      it { expect(serializable_hash).to include(uid: nil) }
    end
  end
end
