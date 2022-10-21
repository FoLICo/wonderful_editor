module Api
  module V1
    class Articles::DraftsController < BaseApiController
      before_action :authenticate_user!

      def index
        articles = current_user.articles.draft.order(updated_at: :desc)
        # articles = Article.all.order(updated_at: :desc)
        # articles = articles.where(status: "draft")
        render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
      end

      def show
        article = current_user.articles.draft.find(params[:id])
        render json: article, serializer: Api::V1::ArticleSerializer
      end
    end
  end
end
