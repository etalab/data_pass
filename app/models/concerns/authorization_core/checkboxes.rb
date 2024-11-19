module AuthorizationCore::Checkboxes
  extend ActiveSupport::Concern
  include AuthorizationCore::Attributes

  included do
    unless respond_to?(:extra_checkboxes)
      def self.extra_checkboxes
        @extra_checkboxes ||= []
      end

      def self.add_checkbox(name)
        add_attribute(name, type: :boolean)

        extra_checkboxes.push(name)
      end
    end
  end

  def all_extra_checkboxes_checked?
    self.class.extra_checkboxes.all? do |extra_checkbox_name|
      public_send(extra_checkbox_name)
    end
  end

  def extra_checkboxes
    self.class.extra_checkboxes
  end
end
