require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なパラメーターを送信したとき" do
      let(:params) do
        { registration: FactoryBot.attributes_for(:user) }
      end

      it "Userのデータが作成できる" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["data"]["name"]).to eq params[:registration][:name] # 上で送った値と、resとして返ってきている値が等しい
        expect(res["data"]["email"]).to eq params[:registration][:email]
      end

      it "作成時にヘッダー情報が取得できる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "不適切なパラメーターを送信したとき" do
      let(:params) do
        { user: FactoryBot.attributes_for(:user) }
      end

      it "Userのデータが作成できない" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "不適切なパラメーター(name無)なとき" do
      let(:params) do
        { registration: FactoryBot.attributes_for(:user, name: nil) }
      end

      it "Userのデータが作成できない" do
        # binding.pry
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["name"]).to eq ["can't be blank"]
        # binding.pry
      end
    end

    context "不適切なパラメーター(email無)なとき" do
      let(:params) do
        { registration: FactoryBot.attributes_for(:user, email: nil) }
      end

      it "Userのデータが作成できない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["email"]).to eq ["can't be blank"]
      end
    end

    context "不適切なパラメーター(password無)なとき" do
      let(:params) do
        { registration: FactoryBot.attributes_for(:user, password: nil) }
      end

      it "Userのデータが作成できない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["password"]).to eq ["can't be blank"]
      end
    end
  end

  describe "POST /auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "適切なパラメーターを送信したとき" do
      let(:existing_user) { create(:user) }
      let(:params) do
        { email: existing_user.email, password: existing_user.password }
      end

      it "ログインできる" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["data"]["email"]).to eq params[:email] # 上で送った値と、resとして返ってきている値が等しい
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "不適切なパラメーター(email相違)なとき" do
      let(:existing_user) { create(:user) }
      let(:params) do
        { email: "foo@gmail.com", password: existing_user.password }
      end

      it "ログインできない" do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["expiry"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end

    context "不適切なパラメーター(password相違)なとき" do
      let(:existing_user) { create(:user) }
      let(:params) do
        { email: existing_user.email, password: "fooooo7" }
      end

      it "ログインできない" do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["expiry"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end
  end

  describe "DELETE /auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ユーザーがログインしている時" do
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
      it "ログアウトできる" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_truthy
        expect(current_user.reload.tokens).to be_blank
        expect(response).to have_http_status(:ok)
      end
    end

    context "ユーザーがログインしていない時" do
      let(:current_user) { create(:user) }
      let(:headers) { { "access-token" => "", "client" => "", "uid" => "" } }
      it "ログアウトできない" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(res["success"]).to eq false
        expect(res["errors"]).to eq ["User was not found or was not logged in."]
      end
    end
  end
end
