class StaticApplicationRecord
  include ActiveModel::Model

  def self.inherited(base)
    base.extend ClassMethods

    base.class_eval do
      private_class_method :values_includes_entry_attribute?
    end
  end

  module ClassMethods
    def all
      fail NotImplementedError
    end

    def unscoped
      yield
    end

    def where(conditions = {})
      return all if conditions.blank?

      all.select do |entry|
        conditions.all? do |attr, values|
          values_includes_entry_attribute?(entry, attr, values)
        end
      end
    end

    def find(id)
      all.find { |entry| entry.id == id } || fail(ActiveRecord::RecordNotFound)
    end

    def values_includes_entry_attribute?(entry, attr, values)
      Array.wrap(values).include?(entry.public_send(attr))
    end
  end

  def id
    fail NotImplementedError
  end

  private

  def value_or_default(value, default)
    value.nil? ? default : value
  end
end
