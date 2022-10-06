# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  context "name を指定しているとき" do
    it "ユーザーが作られる" do
      user = FactoryBot.build(:user)
      # expect(user.valid?).to eq true
      expect(user).to be_valid
    end
  end

  context "name を指定していないとき" do
    it "ユーザー作成に失敗する" do
      user = FactoryBot.build(:user, name: nil)
      # expect(user.invalid?).to eq true
      expect(user).to be_invalid
      # binding.pry
      expect(user.errors.details[:name][0][:error]).to eq :blank
    end
  end

  context "すでに同じ名前の name が存在しているとき" do
    before { create(:user, name: "aaa") }

    it "ユーザー作成に失敗する" do
      user = FactoryBot.build(:user, name: "aaa")
      expect(user).to be_invalid
      # binding.pry
      expect(user.errors.details[:name][0][:error]).to eq :taken
    end
  end
end
