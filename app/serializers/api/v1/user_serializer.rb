class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :password
  has_many :articles, dependent: :destroy
end
