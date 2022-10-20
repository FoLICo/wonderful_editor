module Api
  module V1
    class ArticlesController < BaseApiController
      before_action :authenticate_user!, only: [:create, :update, :destroy]

      def index
        articles = Article.all.order(updated_at: :desc)
        articles = articles.where(status: "published")
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end

      def show
        article = Article.find(params[:id])
        if article.published?
          render json: article, serializer: Api::V1::ArticleSerializer # 出力するデータが配列ではない場合はeach_serializerではなく、serializerを設定
        end
      end

      def create
        # binding.pry
        # article = current_user.articles.new(article_params)
        article = Article.new(article_params)
        # binding.pry
        article.save!
        render json: article, serializer: Api::V1::ArticleSerializer
      end

      def update
        article = current_user.articles.find(params[:id])
        article.update!(update_params)
        render json: article, serializer: Api::V1::ArticleSerializer
      end

      def destroy
        article = current_user.articles.find(params[:id])
        article.destroy!
        render json: article, serializer: Api::V1::ArticleSerializer # 出力するデータが配列ではない場合はeach_serializerではなく、serializerを設定
      end

      private

        def article_params
          # binding.pry
          # params.require(:article).permit(:title, :body)  #.merge(user_id: current_user.id)
          params.require(:article).permit(:title, :body, :status).merge(user_id: current_user.id)
          # binding.pry  #ここのpryは禁物
        end

        def update_params
          params.require(:article).permit(:title, :body, :status)
        end
    end
  end
end
