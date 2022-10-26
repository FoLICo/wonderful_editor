require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    before { create(:article, title: 0, updated_at: 4.days.ago) }
    before { create(:article, status: "published", title: 1, updated_at: 3.days.ago, user: current_user) }
    before { create(:article, status: "published", title: 2, updated_at: 2.days.ago, user: current_user) }
    before { create(:article, status: "published", title: 3, updated_at: 1.days.ago, user: current_user) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    it "ログインユーザーの公開用の記事の一覧を取得できる" do
      subject
      expect(response).to have_http_status(:success)
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "created_at", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email", "password"]
      expect(res[0]["title"]).to eq "3"
      expect(res[0]["status"]).to eq "published"
      expect(res[0]["user"]["id"]).to eq current_user.id
    end
  end
end
