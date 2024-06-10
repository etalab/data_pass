module AuthorizationExtensions::Modalities
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Metrics/MethodLength
    def self.add_modalities(options = {})
      class_eval do
        store_accessor :data, :modalities

        def modalities
          data['modalities'] ||= []
          begin
            JSON.parse(super).sort
          rescue StandardError
            super
          end
        end

        def modalities=(value)
          value = (value || []).compact_blank
          super(value.sort)
        end

        validates :modalities, options[:validation] if options[:validation].present?
      end
    end
    # rubocop:enable Metrics/MethodLength
  end

  def available_modalities
    @available_modalities ||= definition.modalities
  end

end
