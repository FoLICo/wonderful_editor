module Api
  module V1
    class ArticlesController < BaseApiController
      def index
        articles = Article.all.order(updated_at: :desc)
        # 下記でserializerを使って出力できるようにする！
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end
    end
  end
end
