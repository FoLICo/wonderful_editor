module Api
  module V1
    class ArticlesController < BaseApiController
      # before_action :current_user

      def index
        articles = Article.all.order(updated_at: :desc)
        # 下記でserializerを使って出力できるようにする！
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end

      def show
        # binding.pry
        article = Article.find(params[:id])
        # 下記でserializerを使って出力できるようにする！
        render json: article, serializer: Api::V1::ArticleSerializer # 出力するデータが配列ではない場合はeach_serializerではなく、serializerを設定
      end

      def create
        # binding.pry
        # article = current_user.articles.new(article_params)
        article = Article.new(article_params)
        # binding.pry
        article.save!
        render json: article, serializer: Api::V1::ArticleSerializer
      end

      def article_params
        # binding.pry
        # params.require(:article).permit(:title, :body)  #.merge(user_id: current_user.id)
        params.require(:article).permit(:title, :body).merge(user_id: current_user.id)
        # binding.pry  #ここのpryは禁物
      end
    end
  end
end
