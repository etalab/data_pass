module AuthorizationCore::Scopes
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:scopes_enabled?)
      def self.scopes_enabled?
        @scopes_enabled
      end

      # rubocop:disable Metrics/MethodLength
      def self.add_scopes(options = {})
        class_eval do
          store_accessor :data, :scopes

          def scopes
            data['scopes'] ||= []
            begin
              JSON.parse(super).sort
            rescue StandardError
              super
            end
          end

          def scopes=(value)
            value = (value || []).compact_blank
            super(value.sort)
          end

          @scopes_enabled = true

          validates :scopes, options[:validation] if options[:validation].present?
        end

        scope :with_scopes_intersecting, lambda { |scopes|
          where("
            EXISTS (
              SELECT 1
              FROM jsonb_array_elements_text((data -> 'scopes')::jsonb) AS scope
              WHERE scope.value = ANY(ARRAY[?])
            )",
            scopes,)
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end

  def available_scopes
    @available_scopes ||= definition.scopes.select { |scope| scope.available?(self) }
  end

  def included_scopes
    @included_scopes ||= definition.scopes.select(&:included?)
  end

  def disabled_scopes
    @disabled_scopes ||= definition.scopes.select { |scope| scope.disabled_by_config?(self) }
  end

  def legacy_scope_values
    scopes - available_scopes.map(&:value)
  end
end
