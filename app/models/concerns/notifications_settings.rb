module NotificationsSettings
  extend ActiveSupport::Concern

  included do
    def self.add_instruction_boolean_settings(*names)
      AuthorizationDefinition.all.each do |authorization_definition|
        names.each do |name|
          method_name = "instruction_#{name}_for_#{authorization_definition.id.underscore}"

          store_accessor :settings, method_name

          create_boolean_setting_method(method_name)
        end
      end
    end

    def self.create_boolean_setting_method(method_name)
      define_method method_name do
        case settings[method_name]
        when '1'
          true
        when '0'
          false
        else
          settings[method_name].nil? ? true : settings[method_name]
        end
      end
    end
  end
end
