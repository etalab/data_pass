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
      end
      # rubocop:enable Metrics/MethodLength
    end
  end

  def available_scopes
    @available_scopes ||= if displayed_scope_values
                            definition.scopes.select { |scope| displayed_scope_values.include?(scope.value) }
                          else
                            definition.scopes
                          end
  end

  def included_scopes
    @included_scopes ||= definition.scopes.select(&:included?)
  end

  def disabled_scopes
    @disabled_scopes ||= definition.scopes.select { |scope| disabled_scope_values.include?(scope.value) }
  end

  def legacy_scope_values
    scopes - available_scopes.map(&:value)
  end

  private

  def disabled_scope_values
    form.scopes_config[:disabled].presence || []
  end

  def displayed_scope_values
    return if form.scopes_config[:displayed].blank?

    form.scopes_config[:displayed]
  end
end
