class Api::V1::ArticlePreviewSerializer < ActiveModel::Serializer
  attributes :id, :title, :created_at, :updated_at
  belongs_to :user, serializer: Api::V1::UserSerializer
end
