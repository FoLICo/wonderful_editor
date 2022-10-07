# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  # validates :body, { presence: true, length: { maximum: 300 } }

  context "bodyとtitele を指定しているとき" do
    it "記事が作られる" do
      article = FactoryBot.build(:article)
      expect(article).to be_valid
    end
  end

  context "body を指定していないとき" do
    it "コメントの作成に失敗する" do
      article = FactoryBot.build(:article, body: nil)
      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "bodyが300文字以上の時のとき" do
    it "コメントの作成に失敗する" do
      article = FactoryBot.build(:article, body: "a" * 301)
      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :too_long
    end
  end

  # validates :title, { presence: true, length: { maximum: 50 } }
  # context "title を指定しているとき" do  #一番上と同義
  #   it "記事が作られる" do
  #     article = FactoryBot.build(:article)
  #     expect(article).to be_valid
  #   end
  # end

  context "title を指定していないとき" do
    it "コメントの作成に失敗する" do
      article = FactoryBot.build(:article, title: nil)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "titleが50文字以上の時のとき" do
    it "コメントの作成に失敗する" do
      article = FactoryBot.build(:article, title: "a" * 51)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :too_long
    end
  end
end
