require 'rails_helper'

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }
    before{ create(:article, title: 1, updated_at: 3.days.ago) }
    before{ create(:article, title: 2, updated_at: 2.days.ago) }
    before{ create(:article, title: 3, updated_at: 1.days.ago) }


    fit "記事の一覧を取得できる" do
      # binding.pry
      subject
      # binding.pry
      expect(response).to have_http_status(:success)  #正常に通信できているか？
      res = JSON.parse(response.body)  #一覧として帰ってきているデータ数が、beforeで作成したデータ数と一致するか？
      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "created_at", "updated_at", "user"]   #一覧として帰ってきているデータの構成が、beforeで作成したデータと一致するか？
      expect(res[0]["user"].keys).to eq ["id", "email", "password"]   #一覧として帰ってきているデータのうち関連データとして存在するuserがちゃんとできていて、beforeで作成したデータと一致するか？
      expect(res[0]["title"]).to eq "3"  #コントローラのdesc→ascに書き換えたときにresに入る値の順番が入れ替わったので,その時点で表示の順番が入れ替わっている証拠になる
    end
  end

end
