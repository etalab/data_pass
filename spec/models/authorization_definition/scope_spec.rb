RSpec.describe AuthorizationDefinition::Scope do
  describe '#deprecated?' do
    it 'returns true when deprecated_since is present and in the past' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope',
        deprecated_since: Date.yesterday.to_s
      )

      expect(scope).to be_deprecated
    end

    it 'returns false when deprecated_since is not present' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope'
      )

      expect(scope).not_to be_deprecated
    end

    it 'returns false when deprecated_since is in the future' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope',
        deprecated_since: Date.tomorrow.to_s
      )

      expect(scope).not_to be_deprecated
    end
  end

  describe '#entity_created_after_deprecation_date?' do
    subject do
      scope.entity_created_after_deprecation_date?(authorization_request)
    end

    let(:authorization_request) { instance_double(AuthorizationRequest, created_at: created_at) }
    let(:created_at) { Time.zone.now }

    context 'when scope has deprecated_since date' do
      let(:deprecated_date) { '2025-04-17' }
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope',
          deprecated_since: deprecated_date
        )
      end

      context 'when entity was created before the deprecation date' do
        let(:created_at) { Date.parse('2025-04-16').to_time }

        it { is_expected.to be(false) }
      end

      context 'when entity was created on the deprecation date' do
        let(:created_at) { deprecated_date.to_time }

        it { is_expected.to be(true) }
      end

      context 'when entity was created after the deprecation date' do
        let(:created_at) { Date.parse('2025-04-18').to_time }

        it { is_expected.to be(true) }
      end

      context 'when entity has no created_at date' do
        let(:authorization_request) { instance_double(AuthorizationRequest, created_at: nil) }

        it 'returns false when today is before deprecation date' do
          travel_to Date.parse('2025-04-16') do
            expect(subject).to be false
          end
        end

        it 'returns true when today is on or after deprecation date' do
          travel_to Date.parse('2025-04-17') do
            expect(subject).to be true
          end
        end
      end
    end

    context 'when scope has no deprecation settings' do
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope'
        )
      end

      it { is_expected.to be(false) }
    end

    context 'when deprecated_since is an invalid date string' do
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope',
          deprecated_since: 'not-a-date'
        )
      end

      it { is_expected.to be(false) }
    end
  end
end
