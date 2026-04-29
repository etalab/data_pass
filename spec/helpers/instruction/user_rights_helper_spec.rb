require 'rails_helper'

RSpec.describe Instruction::UserRightsHelper do
  describe '#role_badge' do
    subject(:rendered) { helper.role_badge(role_type) }

    context 'with a manager role' do
      let(:role_type) { 'manager' }

      it { is_expected.to include('fr-badge--purple-glycine') }
      it { is_expected.to include('Manager') }
    end

    context 'with an instructor role' do
      let(:role_type) { 'instructor' }

      it { is_expected.to include('fr-badge--pink-tuile') }
      it { is_expected.to include('Instructeur') }
    end

    context 'with a reporter role' do
      let(:role_type) { 'reporter' }

      it { is_expected.to include('fr-badge--yellow-tournesol') }
      it { is_expected.to include('Observateur') }
    end

    context 'with a developer role' do
      let(:role_type) { 'developer' }

      it { is_expected.to include('fr-badge--blue-ecume') }
      it { is_expected.to include('Développeur') }
    end

    context 'with an unknown role' do
      let(:role_type) { 'admin' }

      it 'raises KeyError' do
        expect { rendered }.to raise_error(KeyError)
      end
    end
  end
end
