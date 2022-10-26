module Api
  module V1
    class ArticlesController < BaseApiController
      before_action :authenticate_user!, only: [:create, :update, :destroy]

      def index
        articles = Article.published.order(updated_at: :desc)
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end

      def show
        article = Article.published.find(params[:id])
        render json: article, serializer: Api::V1::ArticleSerializer
      end

      def create
        article = Article.new(article_params)
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
        render json: article, serializer: Api::V1::ArticleSerializer
      end

      private

        def article_params
          params.require(:article).permit(:title, :body, :status).merge(user_id: current_user.id)
        end

        def update_params
          params.require(:article).permit(:title, :body, :status)
        end
    end
  end
end
