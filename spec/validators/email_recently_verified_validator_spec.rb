class EmailRecentlyVerifiedValidatable
  include ActiveModel::Validations
  attr_accessor :email

  def initialize(email:)
    @email = email
  end

  def id
    1
  end

  validates :email, email_recently_verified: true
end

RSpec.describe EmailRecentlyVerifiedValidator do
  subject { EmailRecentlyVerifiedValidatable.new(email:) }

  let(:email_verifier_job) { instance_double(EmailVerifierJob, perform: nil) }

  before do
    allow(EmailVerifierJob).to receive(:new).and_return(email_verifier_job)
  end

  context 'when there is a verified email' do
    let!(:verified_email) { create(:verified_email, status:, verified_at:) }
    let(:email) { verified_email.email }

    context 'when the email was verified less than 1 month ago' do
      let(:status) { :deliverable }
      let(:verified_at) { 1.minute.ago }

      it { is_expected.to be_valid }

      it 'calls EmailVerifierJob' do
        subject.valid?

        expect(email_verifier_job).to have_received(:perform)
      end
    end

    context 'when the email was verified more than 1 month ago' do
      let(:status) { :deliverable }
      let(:verified_at) { 3.months.ago }

      it { is_expected.to be_valid }

      it 'calls EmailVerifierJob' do
        subject.valid?

        expect(email_verifier_job).to have_received(:perform)
      end
    end

    context 'when the email is whitelisted and was verified more than 1 month ago' do
      let(:status) { :whitelisted }
      let(:verified_at) { 3.months.ago }

      it { is_expected.to be_valid }

      it 'calls EmailVerifierJob' do
        subject.valid?

        expect(email_verifier_job).to have_received(:perform)
      end
    end
  end

  context 'when there is no verified email' do
    let(:email) { 'whate@ever.com' }

    it 'calls EmailVerifierJob' do
      subject.valid?

      expect(email_verifier_job).to have_received(:perform)
    end

    context 'when EmailVerifierJob creates a verified email' do
      let(:email_verifier_job) do
        email_verifier_job = instance_double(EmailVerifierJob)

        allow(email_verifier_job).to receive(:perform) do
          create(:verified_email, email:, status:)
        end

        email_verifier_job
      end

      context 'when the email is deliverable' do
        let(:status) { :deliverable }

        it { is_expected.to be_valid }
      end

      context 'when the email is undeliverable' do
        let(:status) { :undeliverable }

        it { is_expected.not_to be_valid }

        it 'adds email_unreachable error on attribute' do
          subject.valid?

          expect(subject.errors[:email].to_s).to include('une adresse email joignable')
        end
      end
    end

    context 'when EmailVerifierJob does not create a verified email' do
      it { is_expected.not_to be_valid }

      it 'adds email_deliverability_unknown error on attribute' do
        subject.valid?

        expect(subject.errors[:email].to_s).to include('pu être vérifiée')
      end
    end

    context 'when EmailVerifierJob raises a timeout error' do
      before do
        allow(email_verifier_job).to receive(:perform).and_raise(EmailVerifierAPI::TimeoutError)
      end

      it { is_expected.not_to be_valid }

      it 'adds email_unreachable error on attribute' do
        subject.valid?

        expect(subject.errors[:email].to_s).to include('pu être vérifiée')
      end
    end
  end
end
