RSpec.describe AuthorizationDefinition::Scope do
  describe '#deprecated?' do
    it 'returns true when deprecated.since is present and in the past' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope',
        deprecated: { since: Date.yesterday.to_s }
      )

      expect(scope).to be_deprecated
    end

    it 'returns false when deprecated.since is not present' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope'
      )

      expect(scope).not_to be_deprecated
    end

    it 'returns false when deprecated.since is in the future' do
      scope = described_class.new(
        name: 'Test Scope',
        value: 'test_scope',
        deprecated: { since: Date.tomorrow.to_s }
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

    context 'when scope has deprecated.since date' do
      let(:deprecated_date) { '2025-04-17' }
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope',
          deprecated: { since: deprecated_date }
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

    context 'when deprecated.since is an invalid date string' do
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope',
          deprecated: { since: 'not-a-date' }
        )
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#available?' do
    subject { scope.available?(request) }

    let(:request) { instance_double(AuthorizationRequest, created_at: created_at, form: form) }
    let(:form) { instance_double(AuthorizationRequestForm, scopes_config: scopes_config) }
    let(:created_at) { Time.zone.now }
    let(:scopes_config) { {} }

    context 'when scope is not deprecated' do
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope'
        )
      end

      context 'when scopes_config[:displayed] is blank' do
        let(:scopes_config) { { displayed: nil } }

        it { is_expected.to be true }
      end

      context 'when scopes_config[:displayed] is empty array' do
        let(:scopes_config) { { displayed: [] } }

        it { is_expected.to be true }
      end

      context 'when scopes_config[:displayed] is not configured' do
        let(:scopes_config) { {} }

        it { is_expected.to be true }
      end

      context 'when scopes_config[:displayed] contains the scope value' do
        let(:scopes_config) { { displayed: %w[test_scope other_scope] } }

        it { is_expected.to be true }
      end

      context 'when scopes_config[:displayed] does not contain the scope value' do
        let(:scopes_config) { { displayed: %w[other_scope] } }

        it { is_expected.to be false }
      end
    end

    context 'when scope is deprecated' do
      let(:deprecated_date) { '2025-04-17' }
      let(:scope) do
        described_class.new(
          name: 'Test Scope',
          value: 'test_scope',
          deprecated: { since: deprecated_date }
        )
      end

      context 'when entity was created before deprecation date' do
        let(:created_at) { Date.parse('2025-04-16').to_time }

        context 'when scopes_config[:displayed] is blank' do
          let(:scopes_config) { { displayed: nil } }

          it { is_expected.to be true }
        end

        context 'when scopes_config[:displayed] contains the scope value' do
          let(:scopes_config) { { displayed: %w[test_scope] } }

          it { is_expected.to be true }
        end

        context 'when scopes_config[:displayed] does not contain the scope value' do
          let(:scopes_config) { { displayed: %w[other_scope] } }

          it { is_expected.to be false }
        end
      end

      context 'when entity was created after deprecation date' do
        let(:created_at) { Date.parse('2025-04-18').to_time }

        context 'when scopes_config is configured' do
          let(:scopes_config) { { displayed: %w[test_scope] } }

          it 'returns false due to deprecation' do
            expect(subject).to be false
          end
        end
      end

      context 'when entity has no created_at date' do
        let(:request) { instance_double(AuthorizationRequest, created_at: nil, form: form) }

        context 'when today is before deprecation date' do
          it 'returns true if scope is in displayed list' do
            travel_to Date.parse('2025-04-16') do
              allow(form).to receive(:scopes_config).and_return({ displayed: %w[test_scope] })
              expect(subject).to be true
            end
          end

          it 'returns true if displayed list is blank' do
            travel_to Date.parse('2025-04-16') do
              allow(form).to receive(:scopes_config).and_return({ displayed: nil })
              expect(subject).to be true
            end
          end
        end

        context 'when today is after deprecation date' do
          it 'returns false regardless of scopes_config' do
            travel_to Date.parse('2025-04-18') do
              allow(form).to receive(:scopes_config).and_return({ displayed: %w[test_scope] })
              expect(subject).to be false
            end
          end
        end
      end
    end

    context 'when hide option is configured' do
      context 'when scope is in hide list' do
        let(:scopes_config) { { hide: %w[test_scope other_scope] } }

        context 'when scope is not deprecated' do
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope'
            )
          end

          it { is_expected.to be false }
        end

        context 'when scope is deprecated but entity was created before deprecation' do
          let(:deprecated_date) { '2025-04-17' }
          let(:created_at) { Date.parse('2025-04-16').to_time }
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope',
              deprecated: { since: deprecated_date }
            )
          end

          it { is_expected.to be false }
        end
      end

      context 'when scope is not in hide list' do
        let(:scopes_config) { { hide: %w[other_scope] } }

        context 'when scope is not deprecated' do
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope'
            )
          end

          it { is_expected.to be true }
        end
      end

      context 'when both hide and displayed are configured' do
        context 'when scope is in hide list (hide takes precedence)' do
          let(:scopes_config) { { hide: %w[test_scope], displayed: %w[test_scope other_scope] } }
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope'
            )
          end

          it 'returns false due to hide taking precedence over displayed' do
            expect(subject).to be false
          end
        end

        context 'when scope is not in hide list but is in displayed list' do
          let(:scopes_config) { { hide: %w[other_scope], displayed: %w[test_scope another_scope] } }
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope'
            )
          end

          it { is_expected.to be true }
        end

        context 'when scope is not in hide list and not in displayed list' do
          let(:scopes_config) { { hide: %w[other_scope], displayed: %w[another_scope] } }
          let(:scope) do
            described_class.new(
              name: 'Test Scope',
              value: 'test_scope'
            )
          end

          it { is_expected.to be false }
        end
      end

      context 'when hide list is empty' do
        let(:scopes_config) { { hide: [] } }
        let(:scope) do
          described_class.new(
            name: 'Test Scope',
            value: 'test_scope'
          )
        end

        it { is_expected.to be true }
      end

      context 'when hide list is nil' do
        let(:scopes_config) { { hide: nil } }
        let(:scope) do
          described_class.new(
            name: 'Test Scope',
            value: 'test_scope'
          )
        end

        it { is_expected.to be true }
      end
    end
  end
end
