RSpec.describe FindOrCreateApplicantFromAPI do
  describe '#call' do
    subject(:result) { described_class.call(applicant_params:) }

    let(:applicant_params) do
      {
        email: 'new-applicant@example.com',
        given_name: 'Jean',
        family_name: 'Dupont'
      }
    end

    context 'when the user does not exist' do
      it { is_expected.to be_a_success }

      it 'creates a new user' do
        expect { result }.to change(User, :count).by(1)
      end

      it 'sets attributes on the created user' do
        user = result.applicant

        expect(user.email).to eq('new-applicant@example.com')
        expect(user.given_name).to eq('Jean')
        expect(user.family_name).to eq('Dupont')
        expect(user.external_id).to be_nil
      end
    end

    context 'when the user already exists with populated attributes' do
      let!(:existing_user) { create(:user, email: 'new-applicant@example.com', given_name: 'Old', family_name: 'Name') }

      it { is_expected.to be_a_success }

      it 'does not create a new user' do
        expect { result }.not_to change(User, :count)
      end

      it 'preserves the existing attributes' do
        user = result.applicant

        expect(user.given_name).to eq('Old')
        expect(user.family_name).to eq('Name')
      end
    end

    context 'when the user already exists with blank attributes' do
      let!(:existing_user) { create(:user, email: 'new-applicant@example.com', given_name: nil, family_name: nil) }

      it 'fills in the missing attributes from the params' do
        user = result.applicant

        expect(user.given_name).to eq('Jean')
        expect(user.family_name).to eq('Dupont')
      end
    end

    context 'when the email has surrounding whitespace' do
      let!(:existing_user) { create(:user, email: 'new-applicant@example.com') }
      let(:applicant_params) do
        {
          email: '  New-Applicant@Example.com  ',
          given_name: 'Jean',
          family_name: 'Dupont'
        }
      end

      it { is_expected.to be_a_success }

      it 'matches the existing user' do
        expect(result.applicant).to eq(existing_user)
      end

      it 'does not create a new user' do
        expect { result }.not_to change(User, :count)
      end
    end

    context 'with optional params' do
      let(:applicant_params) do
        {
          email: 'new-applicant@example.com',
          given_name: 'Jean',
          family_name: 'Dupont',
          job_title: 'Développeur',
          phone_number: '0612345678'
        }
      end

      it 'sets optional attributes' do
        user = result.applicant

        expect(user.job_title).to eq('Développeur')
        expect(user.phone_number).to eq('0612345678')
      end
    end

    context 'with invalid email' do
      let(:applicant_params) do
        {
          email: 'invalid',
          given_name: 'Jean',
          family_name: 'Dupont'
        }
      end

      it { is_expected.to be_a_failure }
    end

    context 'with missing email' do
      let(:applicant_params) do
        {
          given_name: 'Jean',
          family_name: 'Dupont'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not raise NoMethodError on nil email' do
        expect { result }.not_to raise_error
      end

      it 'fails with applicant_invalid and email message' do
        expect(result.error[:key]).to eq(:applicant_invalid)
        expect(result.error[:errors]).to include(match(/email/i))
      end
    end

    context 'with blank email' do
      let(:applicant_params) do
        {
          email: '',
          given_name: 'Jean',
          family_name: 'Dupont'
        }
      end

      it { is_expected.to be_a_failure }

      it 'fails with applicant_invalid and email message' do
        expect(result.error[:key]).to eq(:applicant_invalid)
        expect(result.error[:errors]).to include(match(/email/i))
      end
    end
  end
end
