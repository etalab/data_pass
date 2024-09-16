RSpec.describe EmailVerifierJob do
  subject(:verify_email) { described_class.perform_now(email) }

  let(:email_verifier_api) { instance_double(EmailVerifierAPI, status: email_verifier_api_status) }
  let(:email_verifier_api_status) { 'deliverable' }

  before do
    allow(EmailVerifierAPI).to receive(:new).and_return(email_verifier_api)
  end

  describe 'with an invalid email' do
    let(:email) { 'invalid' }

    it 'does not create a verified email model' do
      expect { verify_email }.not_to change(VerifiedEmail, :count)
    end
  end

  describe 'with a valid email' do
    let(:email) { generate(:email) }

    context 'when there is a user with the email' do
      let!(:user) { create(:user, email:) }

      it 'creates a verified email model' do
        expect { verify_email }.to change(VerifiedEmail, :count).by(1)
      end

      it 'does not call the email verifier API' do
        verify_email

        expect(EmailVerifierAPI).not_to have_received(:new)
      end

      it 'sets the email as verified' do
        verify_email

        verified_email = VerifiedEmail.last

        expect(verified_email.email).to eq(email)
        expect(verified_email.status).to eq('deliverable')
        expect(verified_email.verified_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when it is a whitelisted domain' do
      let(:email) { 'whatever@whatever.gouv.fr' }

      it 'creates a verified email model' do
        expect { verify_email }.to change(VerifiedEmail, :count).by(1)
      end

      it 'does not call the email verifier API' do
        verify_email

        expect(EmailVerifierAPI).not_to have_received(:new)
      end

      it 'sets the email as verified' do
        verify_email

        verified_email = VerifiedEmail.last

        expect(verified_email.email).to eq(email)
        expect(verified_email.status).to eq('deliverable')
        expect(verified_email.verified_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when the email already exists within verified emails' do
      let!(:verified_email) { create(:verified_email, email:) }

      it 'does not create a verified email model' do
        expect { verify_email }.not_to change(VerifiedEmail, :count)
      end

      context 'when the email is whitelisted and verified more than 30 days ago' do
        let!(:verified_email) { create(:verified_email, email:, status: 'whitelisted', verified_at: 31.days.ago) }

        it 'does not call the email verifier API' do
          verify_email

          expect(EmailVerifierAPI).not_to have_received(:new)
        end

        it 'does not update model' do
          expect { verified_email }.not_to change(verified_email, :updated_at)
        end
      end

      context 'when the email is already verified and deliverable' do
        let!(:verified_email) { create(:verified_email, email:, status: 'deliverable', verified_at:) }

        context 'when it was verified less than 30 days ago' do
          let(:verified_at) { 29.days.ago }

          it 'does not call the email verifier API' do
            verify_email

            expect(EmailVerifierAPI).not_to have_received(:new)
          end
        end

        context 'when it was verified more than 30 days ago' do
          let(:verified_at) { 31.days.ago }

          it 'calls the email verifier API' do
            verify_email

            expect(EmailVerifierAPI).to have_received(:new).with(email)
          end
        end
      end

      context 'when the email is not verified' do
        let!(:verified_email) { create(:verified_email, email:, status: %w[unknown risky].sample, verified_at: nil) }

        it 'calls the email verifier api with the email' do
          verify_email

          expect(EmailVerifierAPI).to have_received(:new).with(email)
        end

        context 'when the api returns deliverable status' do
          let(:email_verifier_api_status) { 'deliverable' }

          it 'updates the verified email status' do
            expect { verify_email }.to change { verified_email.reload.status }.to('deliverable')
          end

          it 'updates the verified email verified_at' do
            verify_email

            expect(verified_email.reload.verified_at).to be_within(1.second).of(Time.current)
          end
        end

        context 'when the api returns undeliverable status' do
          let(:email_verifier_api_status) { 'undeliverable' }

          it 'updates the verified email status' do
            expect { verify_email }.to change { verified_email.reload.status }.to('undeliverable')
          end

          it 'updates the verified email verified_at' do
            verify_email

            expect(verified_email.reload.verified_at).to be_within(1.second).of(Time.current)
          end
        end

        context 'when the api returns unknown status' do
          let(:email_verifier_api_status) { 'unknown' }

          it 'does not update the verified email status' do
            expect { verify_email }.not_to change { verified_email.reload.status }
          end

          it 'does not update the verified email verified_at' do
            expect { verify_email }.not_to change { verified_email.reload.verified_at }
          end
        end
      end
    end
  end
end
