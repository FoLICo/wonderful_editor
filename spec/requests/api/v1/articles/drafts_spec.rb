require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    before { create(:article, status: "published", title: 0, updated_at: 4.days.ago, user: current_user) }
    before { create(:article, status: "draft", title: 1, updated_at: 3.days.ago, user: current_user) }
    before { create(:article, status: "draft", title: 2, updated_at: 2.days.ago, user: current_user) }
    before { create(:article, status: "draft", title: 3, updated_at: 1.days.ago, user: current_user) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    it "下書き用の記事の一覧を取得できる" do
      subject
      expect(response).to have_http_status(:success) # 正常に通信できているか？
      res = JSON.parse(response.body) # 一覧として帰ってきているデータ数が、beforeで作成したデータ数と一致するか？
      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "created_at", "updated_at", "status", "user"] # 一覧として帰ってきているデータの構成が、beforeで作成したデータと一致するか？
      expect(res[0]["user"].keys).to eq ["id", "name", "email", "password"] # 一覧として帰ってきているデータのうち関連データとして存在するuserがちゃんとできていて、beforeで作成したデータと一致するか？
      expect(res[0]["title"]).to eq "3" # コントローラのdesc→ascに書き換えたときにresに入る値の順番が入れ替わったので,その時点で表示の順番が入れ替わっている証拠になる
      expect(res[0]["status"]).to eq "draft" # 下書き用のみ表示されているか
      expect(res[0]["status"]).not_to eq "published" # 公開用は表示されないか
    end
  end

  describe "GET /api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "指定したidの下書き用記事データが存在するとき" do
      let(:article_id) { article.id } # ここで急に出てきてもわからないから次でこのuser.idを定義する
      let(:article) { create(:article, user: current_user, status: "draft") } # これでuser.idが何かわかるようになる

      it "その記事のレコードが取得できる" do
        # binding.pry
        subject
        res = JSON.parse(response.body)
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["id"]).to eq article.id
        expect(res["status"]).to eq article.status
        expect(response).to have_http_status(:ok)
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email", "password"]
      end
    end

    context "指定したidの記事のデータが存在しないとき" do
      let(:article_id) { 1_000_000 } # 存在しないものを書くので仮にFactryBotでつくられていたとしてもなかなか被ることがない数字を指定
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) # raiseなのに注意！　データが見つからないこと（＝エラーとなること）を期待している
      end
    end

    context "指定したidが他人の下書き用記事データだったとき" do
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: other_user, status: "draft") }
      let(:other_user) { create(:user) }

      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) # raiseなのに注意！　データが見つからないこと（＝エラーとなること）を期待している
      end
    end
  end
end
