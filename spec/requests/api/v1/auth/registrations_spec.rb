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
end
