module InstructorSettings
  extend ActiveSupport::Concern

  included do
    def self.add_instructor_boolean_settings(*names)
      AuthorizationDefinition.all.each do |authorization_definition|
        names.each do |name|
          method_name = "instruction_#{name}_for_#{authorization_definition.id.underscore}"

          store_accessor :settings, method_name

          define_method method_name do
            settings[method_name].nil? ? true : settings[method_name]
          end
        end
      end
    end
  end
end
