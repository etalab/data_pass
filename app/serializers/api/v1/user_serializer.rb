class API::V1::UserSerializer < ActiveModel::Serializer
  attributes :id,
    :email,
    :given_name,
    :family_name,
    :phone_number
end
