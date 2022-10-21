require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    before { create(:article, title: 0, updated_at: 4.days.ago) }
    before { create(:article, status: "published", title: 1, updated_at: 3.days.ago) }
    before { create(:article, status: "published", title: 2, updated_at: 2.days.ago) }
    before { create(:article, status: "published", title: 3, updated_at: 1.days.ago) }

    it "公開用の記事の一覧を取得できる" do
      subject
      expect(response).to have_http_status(:success) # 正常に通信できているか？
      res = JSON.parse(response.body) # 一覧として帰ってきているデータ数が、beforeで作成したデータ数と一致するか？
      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "created_at", "updated_at", "status", "user"] # 一覧として帰ってきているデータの構成が、beforeで作成したデータと一致するか？
      expect(res[0]["user"].keys).to eq ["id", "name", "email", "password"] # 一覧として帰ってきているデータのうち関連データとして存在するuserがちゃんとできていて、beforeで作成したデータと一致するか？
      expect(res[0]["title"]).to eq "3" # コントローラのdesc→ascに書き換えたときにresに入る値の順番が入れ替わったので,その時点で表示の順番が入れ替わっている証拠になる
      expect(res[0]["status"]).to eq "published" # 公開用のみ表示されているか
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの公開用記事データが存在するとき" do
      let(:article_id) { article.id } # ここで急に出てきてもわからないから次でこのuser.idを定義する
      let(:article) { create(:article, status: "published") } # これでuser.idが何かわかるようになる

      it "その記事のレコードが取得できる" do
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

    context "指定したidが下書き用記事データだったとき" do
      let(:article_id) { article.id } # ここで急に出てきてもわからないから次でこのuser.idを定義する
      let(:article) { create(:article) } # これでuser.idが何かわかるようになる

      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) # raiseなのに注意！　データが見つからないこと（＝エラーとなること）を期待している
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context "（下書き用の）適切なパラメーターを送信したとき" do
      let(:params) do
        { article: FactoryBot.attributes_for(:article) } # デフォでdraftが指定されている
      end

      it "(下書き用の)記事のデータが作成できる" do
        # expect { subject }.to change { Article.count }.by(1) # サブジェクトにどんな変化があったのか⇨article数が一つ増える
        expect { subject }.to change { Article.where(status: "draft").count }.by(1) # サブジェクトにどんな変化があったのか⇨article数が一つ増える
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title] # 上で送った値と、resとして返ってきている値が等しい
        expect(res["body"]).to eq params[:article][:body]
        expect(res["user"]["id"]).to eq current_user.id
        expect(response).to have_http_status(:ok)
        expect(res["status"]).to eq params[:article][:status] # 追加分
      end
    end

    context "（公開用の）適切なパラメーターを送信したとき" do
      let(:params) do
        { article: FactoryBot.attributes_for(:article, status: "published") }
      end

      it "(公開用の)記事のデータが作成できる" do
        expect { subject }.to change { Article.where(status: "published").count }.by(1) # サブジェクトにどんな変化があったのか⇨article数が一つ増える
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title] # 上で送った値と、resとして返ってきている値が等しい
        expect(res["body"]).to eq params[:article][:body]
        expect(res["user"]["id"]).to eq current_user.id
        expect(response).to have_http_status(:ok)
        expect(res["status"]).to eq params[:article][:status] # 追加分
      end
    end

    context "不適切なパラメーターを送信したとき" do
      let(:params) { FactoryBot.attributes_for(:article) }

      it "記事のデータが作成できない" do
        expect { subject }.to raise_error(ActionController::ParameterMissing) # raiseなのに注意！　うまく値を渡せないことを期待している
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    context "ログインユーザーが自身の投稿を更新しようとした時" do # 下書き・更新ともにstatusが元々から、送った値に更新されていればいいので。
      let(:article_id) { article.id }
      let(:article) { create(:article, user: current_user) }

      let(:params) do
        { article: { title: "fff", created_at: 1.day.ago, status: "published" } }
      end

      it "投稿内容を更新できる" do
        expect { subject }.to change { Article.find(article_id).title }.from(article.title).to(params[:article][:title]) # Article.find(article_id)→article.reloadに書き換えられる
        change { Article.find(article_id).status }.from(article.status).to(params[:article][:status]) & # 追加分
          not_change { Article.find(article_id).body } &
          not_change { Article.find(article_id).user_id } &
          not_change { Article.find(article_id).created_at }
      end
    end

    context "ログインユーザーが他人の投稿を更新しようとした時" do
      let(:other_user) { create(:user) }
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: other_user) }

      let(:params) do
        { article: { title: "fff", created_at: 1.day.ago } }
      end

      it "投稿内容を更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "ログインユーザーが自身の(下書き用の)投稿を削除しようとした時" do
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: current_user) }

      it "（下書き用の）投稿内容を削除できる" do
        expect { subject }.to change { Article.where(status: "draft").count }.by(-1) # サブジェクトにどんな変化があったのか⇨article数が一つ増える
      end
    end

    context "ログインユーザーが自身の(公開用の)投稿を削除しようとした時" do
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: current_user, status: "published") }

      it "（公開用の）投稿内容を削除できる" do
        expect { subject }.to change { Article.where(status: "published").count }.by(-1) # サブジェクトにどんな変化があったのか⇨article数が一つ増える
      end
    end

    context "ログインユーザーが他人の投稿を削除しようとした時" do
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }

      it "投稿内容を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
