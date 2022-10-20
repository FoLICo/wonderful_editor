class Api::V1::ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :updated_at, :created_at, :status
  belongs_to :user, serializer: Api::V1::UserSerializer
end
