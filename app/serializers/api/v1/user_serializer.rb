class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :password
  has_many :articles, dependent: :destroy
end
