module Api
  module V1
    class ArticlesController < BaseApiController
      def index
        articles = Article.all.order(updated_at: :desc)
        # 下記でserializerを使って出力できるようにする！
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end

      def show
        # binding.pry
        article = Article.find(params[:id])
        # 下記でserializerを使って出力できるようにする！
        render json: article, serializer: Api::V1::ArticleSerializer  # 出力するデータが配列ではない場合はeach_serializerではなく、serializerを設定
      end
    end
  end
end
