class API::V1::UserSerializer < ActiveModel::Serializer
  attributes :id,
    :email,
    :given_name,
    :family_name
end
