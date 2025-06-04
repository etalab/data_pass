class API::V1::ScopeSerializer < ActiveModel::Serializer
  delegate :deprecated_date, to: :object

  attributes :name,
    :value,
    :group,
    :link,
    :included,
    :disabled,
    :deprecated,
    :deprecated_date

  def included
    object.included?
  end

  def disabled
    object.disabled?
  end

  def deprecated
    object.deprecated?
  end
end
