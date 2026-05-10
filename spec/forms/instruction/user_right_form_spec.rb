require 'rails_helper'

RSpec.describe Instruction::UserRightForm do
  let(:api_entreprise_scope) { 'dinum:api_entreprise' }
  let(:api_particulier_scope) { 'dinum:api_particulier' }
  let(:dinum_fd_scope) { 'dinum:*' }
  let(:manager) { create(:user, roles: ['dinum:api_entreprise:manager']) }

  def valid_right(scope: api_entreprise_scope, role_type: 'reporter')
    { scope:, role_type: }
  end

  describe 'validations' do
    subject(:form) { described_class.new(manager:, **attrs) }

    context 'when email and a valid right are provided' do
      let(:attrs) { { email: 'user@gouv.fr', rights: [valid_right] } }

      it { is_expected.to be_valid }
    end

    context 'when email is blank' do
      let(:attrs) { { email: '', rights: [valid_right] } }

      it 'is invalid with a blank email error' do
        expect(form).not_to be_valid
        expect(form.errors[:email]).to be_present
      end
    end

    context 'when email has an invalid format' do
      let(:attrs) { { email: 'not-an-email', rights: [valid_right] } }

      it { is_expected.not_to be_valid }
    end

    context 'when no right is provided' do
      let(:attrs) { { email: 'user@gouv.fr', rights: [] } }

      it 'is invalid with at_least_one_right on :base' do
        expect(form).not_to be_valid
        expect(form.errors.details[:base]).to include(hash_including(error: :at_least_one_right))
      end
    end

    context 'when a right is incomplete' do
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(role_type: '')] }
      end

      it 'is invalid with incomplete_right on :rights' do
        expect(form).not_to be_valid
        expect(form.errors.details[:rights]).to include(hash_including(error: :incomplete_right))
      end
    end

    context 'when a scope is not in the manager authority' do
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(scope: api_particulier_scope)] }
      end

      it 'is invalid with scope_not_authorized on :rights' do
        expect(form).not_to be_valid
        expect(form.errors.details[:rights]).to include(hash_including(error: :scope_not_authorized))
      end
    end

    context 'when a non-FD-manager tries to grant an FD-wildcard scope' do
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(scope: dinum_fd_scope)] }
      end

      it 'is invalid with scope_not_authorized on :rights' do
        expect(form).not_to be_valid
        expect(form.errors.details[:rights]).to include(hash_including(error: :scope_not_authorized))
      end
    end

    context 'when an FD-manager grants an FD-wildcard scope' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(scope: dinum_fd_scope, role_type: 'instructor')] }
      end

      it { is_expected.to be_valid }
    end

    context 'when a role_type is admin' do
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(role_type: 'admin')] }
      end

      it 'is invalid with role_type_not_allowed on :rights' do
        expect(form).not_to be_valid
        expect(form.errors.details[:rights]).to include(hash_including(error: :role_type_not_allowed))
      end
    end

    context 'when a role_type is not in the allowed list' do
      let(:attrs) do
        { email: 'user@gouv.fr', rights: [valid_right(role_type: 'developer')] }
      end

      it 'is invalid with role_type_not_allowed on :rights' do
        expect(form).not_to be_valid
        expect(form.errors.details[:rights]).to include(hash_including(error: :role_type_not_allowed))
      end
    end
  end

  describe '#to_roles' do
    it 'returns 3-part role strings for each right' do
      form = described_class.new(
        manager:,
        email: 'user@gouv.fr',
        rights: [
          valid_right(role_type: 'reporter'),
          valid_right(role_type: 'instructor')
        ]
      )

      expect(form.to_roles).to eq(
        %w[dinum:api_entreprise:reporter dinum:api_entreprise:instructor]
      )
    end

    it 'supports FD-wildcard scopes' do
      fd_manager = create(:user, roles: ['dinum:*:manager'])
      form = described_class.new(
        manager: fd_manager,
        email: 'user@gouv.fr',
        rights: [{ scope: 'dinum:*', role_type: 'reporter' }]
      )

      expect(form.to_roles).to eq(['dinum:*:reporter'])
    end
  end

  describe 'rights normalization' do
    it 'accepts hashes with string keys' do
      form = described_class.new(
        manager:,
        email: 'user@gouv.fr',
        rights: [{ 'scope' => api_entreprise_scope, 'role_type' => 'reporter' }]
      )

      expect(form).to be_valid
    end

    it 'accepts permitted ActionController::Parameters arrays' do
      params = ActionController::Parameters
        .new(email: 'user@gouv.fr', rights: [valid_right])
        .permit(:email, rights: %i[scope role_type])

      form = described_class.new(manager:, **params.to_h.symbolize_keys)

      expect(form).to be_valid
    end

    it 'deduplicates identical rights' do
      form = described_class.new(
        manager:,
        email: 'user@gouv.fr',
        rights: [valid_right, valid_right]
      )

      expect(form.to_roles).to eq(%w[dinum:api_entreprise:reporter])
    end
  end
end
